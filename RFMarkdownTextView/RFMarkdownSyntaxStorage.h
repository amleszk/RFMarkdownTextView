//
//  RFMarkdownSyntaxStorage.h
//  RFMarkdownTextViewDemo
//
//  Created by Rudd Fawcett on 12/6/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RFMarkdownSyntaxStorage : NSTextStorage

@property (nonatomic) NSDictionary *bodyAttributes;
@property (nonatomic) NSDictionary *boldAttributes;
@property (nonatomic) NSDictionary *strikeAttributes;
@property (nonatomic) NSDictionary *italicAttributes;
@property (nonatomic) NSDictionary *boldItalicAttributes;
@property (nonatomic) NSDictionary *codeAttributes;
@property (nonatomic) NSDictionary *linkAttributes;
@property (nonatomic) NSDictionary *blockQuoteAttributes;

@property (nonatomic) NSDictionary *headerOneAttributes;
@property (nonatomic) NSDictionary *headerTwoAttributes;
@property (nonatomic) NSDictionary *headerThreeAttributes;
@property (nonatomic) NSDictionary *headerFourAttributes;
@property (nonatomic) NSDictionary *headerFiveAttributes;
@property (nonatomic) NSDictionary *headerSixAttributes;

-(NSAttributedString *) attributedString;
- (void)updateHighlightPatterns;
- (void)update;

@end
