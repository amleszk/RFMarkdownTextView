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
    [self createButtonWithTitle:@"Task" andEventHandler:^{
        NSRange selectionRange = self.selectedRange;
        selectionRange.location += 7;
        if (weakSelf.text.length == 0) {
            [weakSelf insertText:@"- [ ] "];
        }
        else {
            [weakSelf insertText:@"\n- [ ] "];
        }
        weakSelf.selectedRange = selectionRange;
    }];

    UIButton *quote =
    [self createButtonWithTitle:@"Quote" andEventHandler:^{
        NSRange selectionRange = self.selectedRange;
        selectionRange.location += 3;
        if (weakSelf.text.length == 0) {
            [weakSelf insertText:@"> "];
        }
        else {
            [weakSelf insertText:@"\n> "];
        }
        weakSelf.selectedRange = selectionRange;
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

#pragma mark - UITextView

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

-(void) insertOrSurroundWithText:(NSString*)text {
    [self insertText:text orWithSelectedText:^(UITextRange *selectedTextRange, NSString *selectedText) {
        [self replaceRange:selectedTextRange withText:[NSString stringWithFormat:@"%@%@%@",text,selectedText,text]];
    }];
}

-(void) insertOrPrependWithText:(NSString*)textToPrepend {
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


@end