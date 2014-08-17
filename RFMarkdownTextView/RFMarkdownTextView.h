//
//  RFMarkdownTextView.h
//  RFMarkdownTextViewDemo
//
//  Created by Rudd Fawcett on 12/1/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFKeyboardToolbar.h"
#import "RFToolbarButton.h"
#import "RFMarkdownSyntaxStorage.h"

extern NSString *const RFMarkdownTextTypePreview;
extern NSString *const RFMarkdownTextTypeHelp;

@protocol RFMarkdownTextViewDelegate;

@interface RFMarkdownTextView : UITextView <UITextViewDelegate>

/// Designated Initializer
- (id)initWithFrame:(CGRect)frame syntaxStorage:(RFMarkdownSyntaxStorage*)syntaxStorage;

- (void)textViewDidChange:(UITextView *)textView NS_REQUIRES_SUPER;

@property (nonatomic,weak) id<RFMarkdownTextViewDelegate> markdownTextViewDelegate;
@property (nonatomic) NSArray *excludedButtonTypes;

@end


@protocol RFMarkdownTextViewDelegate <NSObject>

@optional
-(void) markdownTextView:(RFMarkdownTextView*)markdownTextView didTapHelpWithSender:(id)sender;
-(void) markdownTextView:(RFMarkdownTextView*)markdownTextView didTapPreviewWithSender:(id)sender;

@end