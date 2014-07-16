//
//  RFMarkdownTextView.m
//  RFMarkdownTextViewDemo
//
//  Created by Rudd Fawcett on 12/1/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import "RFMarkdownTextView.h"
#import "UIPasteboard+RFMarkdown.h"

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
        self.inputAccessoryView = [RFKeyboardToolbar toolbarViewWithButtons:[self createMarkdownButtonsForReddit]];
    }
    return self;
}

- (NSArray*) createMarkdownButtonsForReddit {
    
    __weak typeof(self)weakSelf = self;
    UIButton *header =
    [self createButtonWithTitle:@"#" andEventHandler:^{
        [weakSelf insertOrPrependWithText:@"#"];
    }];

    UIButton *bold =
    [self createButtonWithTitle:@"**" andEventHandler:^{
        [weakSelf insertOrSurroundWithText:@"**"];
    }];
    
    UIButton *italics =
    [self createButtonWithTitle:@"*" andEventHandler:^{
        [weakSelf insertOrSurroundWithText:@"*"];
    }];

    UIButton *strike =
    [self createButtonWithTitle:@"~~" andEventHandler:^{
        [weakSelf insertOrSurroundWithText:@"~~"];
    }];

    UIButton *code =
    [self createButtonWithTitle:@"Code" andEventHandler:^{
        [weakSelf insertCodeBlockMarkdownIfNeeded];
    }];
    
    UIButton *quote =
    [self createButtonWithTitle:@"Quote" andEventHandler:^{
        [weakSelf insertQuoteItemIfNeeded];
    }];

    UIButton *link =
    [self createButtonWithTitle:@"Link" andEventHandler:^{
        [weakSelf insertLinkMarkdown];
    }];

    UIButton *bullet =
    [self createButtonWithTitle:@"Bullet" andEventHandler:^{
        [weakSelf insertListItemIfNeeded];
    }];

    UIButton *numbers =
    [self createButtonWithTitle:@"Numbers" andEventHandler:^{
        [weakSelf insertNumberItemIfNeeded];
    }];

    return @[header,
             bold,
             italics,
             strike,
             quote,
             code,
             link,
             bullet,
             numbers];
}

- (RFToolbarButton*)createButtonWithTitle:(NSString*)title andEventHandler:(void(^)())handler {
    RFToolbarButton *button = [RFToolbarButton buttonWithTitle:title];
    [button addEventHandler:handler forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

#pragma mark - UITextView overrides

-(NSString*) text {
    return [[self attributedText] string];
}

-(NSAttributedString*) attributedText {
    return [_syntaxStorage attributedString];
}

-(void) setDelegate:(id<UITextViewDelegate>)delegate {
    if (delegate) {
        NSAssert(delegate == self, @"Overriding UITextViewDelegate for %@",self);
    } else {
        [super setDelegate:delegate];
    }
}

-(void) setAttributedText:(NSAttributedString *)attributedText {
    _syntaxStorage = [RFMarkdownSyntaxStorage new];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}];
    [_syntaxStorage appendAttributedString:attrString];
    [_syntaxStorage appendAttributedString:attributedText];
    [_syntaxStorage setAttributedString:[[NSMutableAttributedString alloc] initWithAttributedString:attributedText]];
    [_syntaxStorage addLayoutManager:self.layoutManager];
    [super setAttributedText:attributedText];
}


#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [_syntaxStorage update];
}


#pragma mark - Text handling

#pragma mark Helpers

-(void) offsetSelectionRange:(NSRange)selectionRange location:(NSUInteger)location length:(NSUInteger)length
{
    selectionRange.location += location;
    selectionRange.length = length;
    self.selectedRange = selectionRange;
}

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

#pragma mark Links / Images

-(void) insertImageMarkdown {
    [self withNoSelection:^{
        NSRange selectionRange = self.selectedRange;
        [self insertText:@"[Alt Text](image.png)"];
        [self offsetSelectionRange:selectionRange location:1 length:8];
    } orWithSelectedText:^(UITextRange *selectedTextRange, NSString *selectedText) {
        NSString *textWithLinkFormatting = [NSString stringWithFormat:@"[%@](image.png)",selectedText];
        NSRange selectionRange = self.selectedRange;
        [self replaceRange:selectedTextRange withText:textWithLinkFormatting];
        NSUInteger newSelectionCaretLocationOffset = [textWithLinkFormatting length] - 1;
        [self offsetSelectionRange:selectionRange location:newSelectionCaretLocationOffset length:0];
    }];
}

static NSString* const markupURLStringExample = @"http://";

/// When selected text, surround with link markdown, when no selected text insert an example and select it. In both cases if the user has copied a valid URL it will be populated in the link section
-(void) insertLinkMarkdown {
    __block NSString *pasteboardValidURLString = [[UIPasteboard generalPasteboard] validURLString];
    
    [self withNoSelection:^{
        NSRange selectionRange = self.selectedRange;
        [self insertText:[NSString stringWithFormat:@"[Click Here](%@)", pasteboardValidURLString ?: markupURLStringExample]];
        [self offsetSelectionRange:selectionRange location:1 length:10];
        
    } orWithSelectedText:^(UITextRange *selectedTextRange, NSString *selectedText) {
        NSString *textWithLinkFormatting = [NSString stringWithFormat:@"[%@](%@)",selectedText, pasteboardValidURLString ?: markupURLStringExample];
        NSRange selectionRange = self.selectedRange;
        [self replaceRange:selectedTextRange withText:textWithLinkFormatting];

        if (pasteboardValidURLString == nil) {
            NSUInteger newSelectionCaretLocationOffset = [textWithLinkFormatting length] - 1;
            [self offsetSelectionRange:selectionRange location:newSelectionCaretLocationOffset length:0];
        }

    }];
}

#pragma mark Prepending to start of line

static NSString* const codeMarkdown = @"    ";

-(void) insertCodeBlockMarkdownIfNeeded{
    [self insertFirstLineItemIfNeededWithMarkdownString:codeMarkdown];
}

static NSString* const listItemMarkdown = @"- ";

-(void) insertListItemIfNeeded{
    [self insertFirstLineItemIfNeededWithMarkdownString:listItemMarkdown];
}


static NSString* const numberItemMarkdown = @"1. ";

-(void) insertNumberItemIfNeeded{
    [self insertFirstLineItemIfNeededWithMarkdownString:numberItemMarkdown];
}


static NSString* const quoteMarkdown = @"> ";

-(void) insertQuoteItemIfNeeded{
    [self insertFirstLineItemIfNeededWithMarkdownString:quoteMarkdown];
}

/// Find an existing first line item markdown at the beginning of the line, if one is found no action needed. If one is not found a list item markdown will be inserted at the begining of the line
-(void) insertFirstLineItemIfNeededWithMarkdownString:(NSString*)markdownString {
    
    NSRange caretLineRange = [self getCaretLineRange];
    NSString *caretLineText = [self.text substringWithRange:caretLineRange];
    if ([caretLineText hasPrefix:markdownString]) {
        //No action
    }
    else if ([caretLineText length] == 0) {
        [self insertText:markdownString];
    }
    else { //Prepend the list item markup to this line
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
        [attrString replaceCharactersInRange:caretLineRange withString:[NSString stringWithFormat:@"%@%@",markdownString,caretLineText]];
        
        self.attributedText = attrString;
        self.selectedRange = NSMakeRange(caretLineRange.location+[markdownString length], 0);
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

#pragma mark Code block

@end