//
//  RFMarkdownTextView.m
//  RFMarkdownTextViewDemo
//
//  Created by Rudd Fawcett on 12/1/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

NSString *const RFMarkdownTextTypePreview = @"preview";
NSString *const RFMarkdownTextTypeHelp = @"help";
NSString *const RFMarkdownTextTypeImageUpload = @"image_upload";

#import "RFMarkdownTextView.h"
#import "UIPasteboard+RFMarkdown.h"

@interface RFMarkdownTextView ()

@property (strong,nonatomic) RFMarkdownSyntaxStorage *syntaxStorage;

@end

@implementation RFMarkdownTextView

- (id)initWithFrame:(CGRect)frame syntaxStorage:(RFMarkdownSyntaxStorage*)syntaxStorage
{
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:@"" attributes:syntaxStorage.bodyAttributes];
    
    _syntaxStorage = syntaxStorage;
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
    }
    return self;
}

- (NSArray*) createMarkdownButtonsForReddit {
    
    __weak typeof(self)weakSelf = self;
    UIButton *header =
    [self createButtonWithTitle:@"#" andEventHandler:^(id sender){
        [weakSelf insertHeaderMarkdownIfNeeded];
    }];

    UIButton *bold =
    [self createButtonWithTitle:@"**" andEventHandler:^(id sender){
        [weakSelf insertOrSurroundWithText:@"**"];
    }];
    
    UIButton *italics =
    [self createButtonWithTitle:@"*" andEventHandler:^(id sender){
        [weakSelf insertOrSurroundWithText:@"*"];
    }];

    UIButton *strike =
    [self createButtonWithTitle:@"~~" andEventHandler:^(id sender){
        [weakSelf insertOrSurroundWithText:@"~~"];
    }];

    UIButton *code =
    [self createButtonWithTitle:@"Code" andEventHandler:^(id sender){
        [weakSelf insertCodeBlockMarkdownIfNeeded];
    }];
    
    UIButton *quote =
    [self createButtonWithTitle:@"Quote" andEventHandler:^(id sender){
        [weakSelf insertQuoteItemIfNeeded];
    }];

    UIButton *link =
    [self createButtonWithTitle:@"Link" andEventHandler:^(id sender){
        [weakSelf insertLinkMarkdown];
    }];

    UIButton *bullet =
    [self createButtonWithTitle:@"Bullet" andEventHandler:^(id sender){
        [weakSelf insertListItemIfNeeded];
    }];

    UIButton *numbers =
    [self createButtonWithTitle:@"Numbers" andEventHandler:^(id sender){
        [weakSelf insertNumberItemIfNeeded];
    }];

    UIButton *undo =
    [self createButtonWithTitle:@"Undo" andEventHandler:^(id sender){
        [[weakSelf undoManager] undo];
    }];

    NSArray *buttons = @[header,
                          bold,
                          italics,
                          strike,
                          quote,
                          code,
                          link,
                          bullet,
                          numbers,
                          undo];

    if (![self.excludedButtonTypes containsObject:RFMarkdownTextTypeImageUpload]) {
        UIButton *imageUpload =
        [self createButtonWithTitle:@"Upload image" andEventHandler:^(id sender){
            if ([weakSelf.markdownTextViewDelegate respondsToSelector:@selector(markdownTextView:didTapImageUploadWithSender:)]) {
                [weakSelf.markdownTextViewDelegate markdownTextView:self didTapImageUploadWithSender:sender];
            }
        }];
        buttons = [buttons arrayByAddingObject:imageUpload];
    }

    if (![self.excludedButtonTypes containsObject:RFMarkdownTextTypePreview]) {
        UIButton *preview =
        [self createButtonWithTitle:@"Preview" andEventHandler:^(id sender){
            if ([weakSelf.markdownTextViewDelegate respondsToSelector:@selector(markdownTextView:didTapPreviewWithSender:)]) {
                [weakSelf.markdownTextViewDelegate markdownTextView:self didTapPreviewWithSender:sender];
            }
        }];
        buttons = [buttons arrayByAddingObject:preview];
    }

    if (![self.excludedButtonTypes containsObject:RFMarkdownTextTypeHelp]) {
        UIButton *help =
        [self createButtonWithTitle:@"Help" andEventHandler:^(id sender){
            if ([weakSelf.markdownTextViewDelegate respondsToSelector:@selector(markdownTextView:didTapHelpWithSender:)]) {
                [weakSelf.markdownTextViewDelegate markdownTextView:self didTapHelpWithSender:sender];
            }
        }];
        buttons = [buttons arrayByAddingObject:help];
    }
    
    return buttons;
}

- (RFToolbarButton*)createButtonWithTitle:(NSString*)title andEventHandler:(void(^)())handler {
    RFToolbarButton *button = [RFToolbarButton buttonWithTitle:title];
    [button addEventHandler:handler forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

#pragma mark - UIView overrides

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    if (newWindow) {
        [self updateInputAccessoryView];
    }
}

#pragma mark - UITextView overrides

-(NSString*) text {
    return [[self attributedText] string];
}

-(NSAttributedString*) attributedText {
    return [_syntaxStorage attributedString];
}

-(void) setDelegate:(id<UITextViewDelegate>)delegate
{
    if (delegate && delegate != self) {
        NSAssert(NO, @"setting delegate disabled, use rcDelegate");
    } else {
        [super setDelegate:delegate];
    }
}

-(void) setText:(NSString *)text {
    [_syntaxStorage beginEditing];
    NSAttributedString *attributedString = text ? [[NSAttributedString alloc] initWithString:text attributes:_syntaxStorage.bodyAttributes] : nil;
    [_syntaxStorage setAttributedString:attributedString];
    [_syntaxStorage endEditing];
}

-(void) setAttributedText:(NSAttributedString *)attributedText {
    [_syntaxStorage beginEditing];
    [_syntaxStorage setAttributedString:attributedText];
    [_syntaxStorage endEditing];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    [_syntaxStorage update];
}

#pragma mark - Toolbar handling

-(void) updateInputAccessoryView
{
    if (!self.inputAccessoryView && self.toolbarEnabled) {
        self.inputAccessoryView = [RFKeyboardToolbar toolbarViewWithButtons:[self createMarkdownButtonsForReddit]];
    } else if (self.inputAccessoryView && !self.toolbarEnabled) {
        self.inputAccessoryView = nil;
    }
}

- (void)setToolbarEnabled:(BOOL)toolbarEnabled
{
    if (toolbarEnabled != _toolbarEnabled) {
        _toolbarEnabled = toolbarEnabled;
        if (!_toolbarEnabled) {
            [self updateInputAccessoryView];
        }
    }
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
    __block BOOL offsetToMarkupExample = NO;
    if (!pasteboardValidURLString) {
        pasteboardValidURLString = markupURLStringExample;
        offsetToMarkupExample = YES;
    }
    
    [self withNoSelection:^{
        NSRange selectionRange = self.selectedRange;
        [self insertText:[NSString stringWithFormat:@"[Click Here](%@)", pasteboardValidURLString]];
        [self offsetSelectionRange:selectionRange location:1 length:10];
        
    } orWithSelectedText:^(UITextRange *selectedTextRange, NSString *selectedText) {
        NSString *textWithLinkFormatting = [NSString stringWithFormat:@"[%@](%@)",selectedText, pasteboardValidURLString];
        NSRange selectionRange = self.selectedRange;
        [self replaceRange:selectedTextRange withText:textWithLinkFormatting];

        if (offsetToMarkupExample) {
            NSUInteger newSelectionCaretLocationOffset = [textWithLinkFormatting length] - 1;
            [self offsetSelectionRange:selectionRange location:newSelectionCaretLocationOffset length:0];
        }

    }];
}

-(void) insertLinkMarkdownWithDescriptionText:(NSString*)descriptionText urlString:(NSString*)urlString
{
    NSParameterAssert(urlString);
    if (!urlString) {
        return;
    }
    
    [self withNoSelection:^{
        NSRange selectionRange = self.selectedRange;
        [self insertText:[NSString stringWithFormat:@"[%@](%@)", descriptionText, urlString]];
        [self offsetSelectionRange:selectionRange location:1 length:[descriptionText length]];
        
    } orWithSelectedText:^(UITextRange *selectedTextRange, NSString *selectedText) {
        NSString *textWithLinkFormatting = [NSString stringWithFormat:@"[%@](%@)",selectedText, urlString];
        [self replaceRange:selectedTextRange withText:textWithLinkFormatting];
    }];
    
}

#pragma mark Prepending to start of line

static NSString* const headerMarkdown = @"#";

-(void) insertHeaderMarkdownIfNeeded{
    [self insertFirstLineItemIfNeededWithMarkdownString:headerMarkdown allowRepeatInsertions:YES];
}

static NSString* const codeMarkdown = @"    ";

-(void) insertCodeBlockMarkdownIfNeeded{
    [self insertFirstLineItemIfNeededWithMarkdownString:codeMarkdown allowRepeatInsertions:NO];
}

static NSString* const listItemMarkdown = @"- ";

-(void) insertListItemIfNeeded{
    [self insertFirstLineItemIfNeededWithMarkdownString:listItemMarkdown allowRepeatInsertions:NO];
}


static NSString* const numberItemMarkdown = @"1. ";

-(void) insertNumberItemIfNeeded{
    [self insertFirstLineItemIfNeededWithMarkdownString:numberItemMarkdown allowRepeatInsertions:NO];
}


static NSString* const quoteMarkdown = @"> ";

-(void) insertQuoteItemIfNeeded{
    [self insertFirstLineItemIfNeededWithMarkdownString:quoteMarkdown allowRepeatInsertions:NO];
}

/// Find an existing first line item markdown at the beginning of the line, if one is found no action needed. If one is not found a list item markdown will be inserted at the begining of the line
-(void) insertFirstLineItemIfNeededWithMarkdownString:(NSString*)markdownString allowRepeatInsertions:(BOOL)allowRepeatInsertions {
    
    NSUInteger caretLocation = self.selectedRange.location;
    NSRange caretLineRange = [self getCaretLineRange];
    NSString *caretLineText = [self.text substringWithRange:caretLineRange];
    
    if (!allowRepeatInsertions && [caretLineText hasPrefix:markdownString]) {
        //No action
    }
    else if ([caretLineText length] == 0) {
        [self insertText:markdownString];
    }
    else { //Prepend the list item markup to this line
        NSTextStorage *textStorage = self.syntaxStorage;
        [textStorage replaceCharactersInRange:caretLineRange withString:[NSString stringWithFormat:@"%@%@",markdownString,caretLineText]];
        
        self.selectedRange = NSMakeRange(caretLocation+[markdownString length], 0);
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