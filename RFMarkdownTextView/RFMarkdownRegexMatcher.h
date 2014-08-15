//
//  RFMarkdownRegexMatcher.h
//  RFMarkdownTextViewDemo
//
//  Created by al on 14/08/2014.
//  Copyright (c) 2014 Rex Finn. All rights reserved.
//

typedef NS_ENUM(NSInteger, RFMarkdownRegexMatchType)
{
    RFMarkdownRegexMatchTypeBold = 0,
    RFMarkdownRegexMatchTypeItalics,
    RFMarkdownRegexMatchTypeBoldItalics,
    RFMarkdownRegexMatchTypeStrike,
    RFMarkdownRegexMatchTypeLink,
    
    RFMarkdownRegexMatchTypeHeader1,
    RFMarkdownRegexMatchTypeHeader2,
    RFMarkdownRegexMatchTypeHeader3,
    RFMarkdownRegexMatchTypeHeader4,
    RFMarkdownRegexMatchTypeHeader5,
    RFMarkdownRegexMatchTypeHeader6,
    
    RFMarkdownRegexMatchTypeCode,
    RFMarkdownRegexMatchTypeBlockQuote
};

@interface RFMarkdownRegexMatcher : NSObject

-(NSArray *) markdownTokensForString:(NSString*)markdownString searchRange:(NSRange)searchRange;

@end

@interface RFMarkdownRegexMatch : NSObject

@property (nonatomic) NSRange matchRange;
@property (nonatomic) RFMarkdownRegexMatchType matchType;
@property (nonatomic) BOOL stripAllOtherAttributes;

@end