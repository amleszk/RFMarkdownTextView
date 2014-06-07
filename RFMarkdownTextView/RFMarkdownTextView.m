//
//  RFMarkdownTextView.m
//  RFMarkdownTextViewDemo
//
//  Created by Rudd Fawcett on 12/1/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import "RFMarkdownTextView.h"

@interface RFMarkdownTextView ()

@property (strong,nonatomic) RFMarkdownSyntaxStorage *syntaxStorage;

@end

@implementation RFMarkdownTextView

- (id)initWithFrame:(CGRect)frame {
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}];
    
    _syntaxStorage = [RFMarkdownSyntaxStorage new];
    [_syntaxStorage appendAttributedString:attrString];
    
    CGRect newTextViewRect = frame;
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    
    CGSize containerSize = CGSizeMake(newTextViewRect.size.width,  CGFLOAT_MAX);
    NSTextContainer *container = [[NSTextContainer alloc] initWithSize:containerSize];
    container.widthTracksTextView = YES;
    
    [layoutManager addTextContainer:container];
    [_syntaxStorage addLayoutManager:layoutManager];
    
    self = [super initWithFrame:frame textContainer:container];
    if (self) {
        self.delegate = self;
        self.inputAccessoryView = [RFKeyboardToolbar toolbarViewWithButtons:[self createMarkdownButtons]];
    }
    return self;
}

- (NSArray*) createMarkdownButtons {
    __weak typeof(self)weakSelf = self;
    UIButton *header =
    [self createButtonWithTitle:@"#" andEventHandler:^{
        [weakSelf insertOrPrependWithText:@"#"];
    }];

    UIButton *boldItalics =
    [self createButtonWithTitle:@"*" andEventHandler:^{
        [weakSelf insertOrSurroundWithText:@"*"];
    }];

    UIButton *underscore =
    [self createButtonWithTitle:@"_" andEventHandler:^{
        [weakSelf insertOrSurroundWithText:@"_"];
    }];

    UIButton *code =
    [self createButtonWithTitle:@"`" andEventHandler:^{
        [weakSelf insertOrSurroundWithText:@"`"];
    }];

    UIButton *mention =
    [self createButtonWithTitle:@"@" andEventHandler:^{
        [weakSelf insertOrPrependWithText:@"@"];
    }];

    UIButton *link =
    [self createButtonWithTitle:@"Link" andEventHandler:^{
        NSRange selectionRange = self.selectedRange;
        selectionRange.location += 1;
        [weakSelf insertText:@"[]()"];
        weakSelf.selectedRange = selectionRange;
    }];

    UIButton *codeBlock =
    [self createButtonWithTitle:@"Codeblock" andEventHandler:^{
        NSRange selectionRange = self.selectedRange;
        if (weakSelf.text.length == 0) {
            selectionRange.location += 3;
            [weakSelf insertText:@"```\n```"];
        }
        else {
            selectionRange.location += 4;
            [weakSelf insertText:@"\n```\n```"];
        }
        weakSelf.selectedRange = selectionRange;
    }];

    UIButton *image =
    [self createButtonWithTitle:@"Image" andEventHandler:^{
        NSRange selectionRange = self.selectedRange;
        selectionRange.location += 2;
        [weakSelf insertText:@"![]()"];
        weakSelf.selectedRange = selectionRange;
    }];

    UIButton *task =
    [self createButtonWithTitle:@"List" andEventHandler:^{
        [weakSelf insertListItemIfNeeded];
    }];

    UIButton *quote =
    [self createButtonWithTitle:@"Quote" andEventHandler:^{
        [weakSelf insertOrPrependWithText:@">"];
    }];
    

    return @[header,
             boldItalics,
             underscore,
             code,
             mention,
             link,
             codeBlock,
             image,
             task,
             quote];
}

- (RFToolbarButton*)createButtonWithTitle:(NSString*)title andEventHandler:(void(^)())handler {
    RFToolbarButton *button = [RFToolbarButton buttonWithTitle:title];
    [button addEventHandler:handler forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

#pragma mark - UITextView overrides

-(void) setDelegate:(id<UITextViewDelegate>)delegate {
    [super setDelegate:delegate];
    NSAssert(delegate == self, @"Overriding UITextViewDelegate for %@",self);
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [_syntaxStorage update];
}


#pragma mark - Text handling

-(void) withNoSelection:(void (^)(void))noSelectionBlock
      orWithSelectedText:(void (^)(UITextRange *selectedTextRange, NSString *selectedText))selectedTextBlock
{
    UITextRange *range = self.selectedTextRange;
    if ([range isEmpty] == NO) {
        NSString *selectedText = [self textInRange:self.selectedTextRange];
        if (selectedTextBlock) {
            selectedTextBlock(range,selectedText);
        }
    } else {
        if (noSelectionBlock) {
            noSelectionBlock();
        }
    }
}

-(void) insertText:(NSString*)text orWithSelectedText:(void (^)(UITextRange *selectedTextRange, NSString *selectedText))selectedTextBlock
{
    [self withNoSelection:^{
        [self insertText:text];
    } orWithSelectedText:^(UITextRange *selectedTextRange, NSString *selectedText) {
        if (selectedTextBlock) {
            selectedTextBlock(selectedTextRange,selectedText);
        }
    }];
}

-(void) insertOrSurroundWithText:(NSString*)textToSurround {
    NSAssert([textToSurround length], @"Expected non empty string %@",self);
    
    [self insertText:textToSurround orWithSelectedText:^(UITextRange *selectedTextRange, NSString *selectedText) {
        NSRange selectedRange = self.selectedRange;
        [self replaceRange:selectedTextRange withText:[NSString stringWithFormat:@"%@%@%@",textToSurround,selectedText,textToSurround]];
        
        selectedRange.location += [textToSurround length];
        self.selectedRange = selectedRange;
    }];
}

-(void) insertOrPrependWithText:(NSString*)textToPrepend {
    NSAssert([textToPrepend length], @"Expected non empty string %@",self);
    
    [self insertText:textToPrepend orWithSelectedText:^(UITextRange *selectedTextRange, NSString *selectedText) {
        
        //Selected range must be saved before replacing the text
        NSRange selectedRange = self.selectedRange;
        selectedRange.length = 0;
        
        [self replaceRange:selectedTextRange withText:[NSString stringWithFormat:@"%@%@",textToPrepend,selectedText]];

        //If the string the caret is preceeding is our special character, push caret forward
        NSString *textViewText = self.text;
        NSInteger characterAtCaretCounter = selectedRange.location + 1;
        while (YES) {
            NSString* characterAtCaret = [textViewText substringWithRange:NSMakeRange(characterAtCaretCounter, 1)];
            if (![characterAtCaret isEqualToString:textToPrepend]) {
                break;
            }
            characterAtCaretCounter ++;
        }
        selectedRange.location = characterAtCaretCounter;
        
        self.selectedRange = selectedRange;
    }];
}

static NSString* const listItemMarkup = @"- ";

/// Find an existing list item markdown at the beginning of the line, if one is found no action needed. If one is not found a list item markdown will be inserted at the begining of the line
-(void) insertListItemIfNeeded {
    
    NSRange caretLineRange = [self getCaretLineRange];
    NSString *caretLineText = [self.text substringWithRange:caretLineRange];
    if ([caretLineText hasPrefix:listItemMarkup]) {
        //No action
    }
    else if ([caretLineText length] == 0) {
        [self insertText:listItemMarkup];
    }
    else { //Prepend the list item markup to this line
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
        [attrString replaceCharactersInRange:caretLineRange withString:[NSString stringWithFormat:@"%@%@",listItemMarkup,caretLineText]];
        
        self.attributedText = attrString;
        [self textViewDidChange:self];
        self.selectedRange = NSMakeRange(caretLineRange.location+[listItemMarkup length], 0);
    }
}

/// Returns the line range of the current location of the caret, regardless of selection. If caret is at the beginning of a new line, length is zero
-(NSRange) getCaretLineRange
{
    NSUInteger caretLocation = self.selectedRange.location;
    NSString *text = self.text;
    NSUInteger caretLocationLineEnd = caretLocation;
    while (caretLocationLineEnd < [text length] && [text characterAtIndex:caretLocationLineEnd] != '\n') {
        caretLocationLineEnd++;
    }
    NSUInteger caretLocationLineStart = caretLocation;
    while (caretLocationLineStart > 0) {
        if (caretLocationLineStart > 1 && [text characterAtIndex:caretLocationLineStart-1] == '\n') {
            break;
        }
        caretLocationLineStart--;
    }
    NSRange caretLineRange = NSMakeRange(caretLocationLineStart, caretLocationLineEnd-caretLocationLineStart);
    return caretLineRange;
}

@end