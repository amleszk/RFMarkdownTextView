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

@property (nonatomic) NSDictionary *headerOneAttributes;
@property (nonatomic) NSDictionary *headerTwoAttributes;
@property (nonatomic) NSDictionary *headerThreeAttributes;
@property (nonatomic) NSDictionary *headerFourAttributes;
@property (nonatomic) NSDictionary *headerFiveAttributes;
@property (nonatomic) NSDictionary *headerSixAttributes;

-(NSAttributedString *) attributedString;

- (void)update;

-(instancetype) initWithBodyFont:(UIFont*)bodyFont
                      bodyColour:(UIColor*)bodyColour
                      linkColour:(UIColor*)linkColour
                        boldFont:(UIFont*)boldFont
                     italicsFont:(UIFont*)italicsFont
                 boldItalicsFont:(UIFont*)boldItalicsFont
                   headerOneFont:(UIFont*)headerOneFont
                   headerTwoFont:(UIFont*)headerTwoFont
                 headerThreeFont:(UIFont*)headerThreeFont
                  headerFourFont:(UIFont*)headerFourFont
                  headerFiveFont:(UIFont*)headerFiveFont
                   headerSixFont:(UIFont*)headerSixFont;
@end
