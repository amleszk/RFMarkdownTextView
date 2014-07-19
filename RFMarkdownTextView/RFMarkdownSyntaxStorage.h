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
@property (nonatomic) NSDictionary *italicAttributes;
@property (nonatomic) NSDictionary *boldItalicAttributes;
@property (nonatomic) NSDictionary *codeAttributes;
@property (nonatomic) NSDictionary *linkAttributes;

-(NSAttributedString *) attributedString;

- (void)update;

-(instancetype) initWithBodyFont:(UIFont*)bodyFont
                      bodyColour:(UIColor*)bodyColour
                      linkColour:(UIColor*)linkColour
                        boldFont:(UIFont*)boldFont
                     italicsFont:(UIFont*)italicsFont
                 boldItalicsFont:(UIFont*)boldItalicsFont;

@end
