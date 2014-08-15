//
//  RFMarkdownRegexMatcher.m
//  RFMarkdownTextViewDemo
//
//  Created by al on 14/08/2014.
//  Copyright (c) 2014 Rex Finn. All rights reserved.
//

#import "RFMarkdownRegexMatcher.h"

@implementation RFMarkdownRegexMatch
@end

@interface RFMarkdownRegexMatcher ()
@property (nonatomic) NSMutableDictionary *markdownRegularExpressionsToType;
@end

@implementation RFMarkdownRegexMatcher

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSDictionary *markdownRegularExpressionsStringsToType = @{
            @"(?:\\*\\*\\*)(?:[^\\*]+?)(?:\\*\\*\\*)" : @(RFMarkdownRegexMatchTypeBoldItalics),
            //look behind and lookahead for no extra '*'
            @"(?<!\\*)(?:\\*\\*)(?:[^\\*]+?)(?:\\*\\*)(?!\\*)" : @(RFMarkdownRegexMatchTypeBold),
            //look behind and lookahead for no extra '*'
            @"(?<!\\*)\\*(?:[^\\*]+?)\\*(?!\\*)" : @(RFMarkdownRegexMatchTypeItalics),
            @"(?:~~)(?:[^~]+?)(?:~~)" : @(RFMarkdownRegexMatchTypeStrike),
            
            @"^#(?:[^#]+)" : @(RFMarkdownRegexMatchTypeHeader1),
            @"^##(?:[^#]+)" : @(RFMarkdownRegexMatchTypeHeader2),
            @"^###(?:[^#]+)" : @(RFMarkdownRegexMatchTypeHeader3),
            @"^####(?:[^#]+)" : @(RFMarkdownRegexMatchTypeHeader4),
            @"^#####(?:[^#]+)" : @(RFMarkdownRegexMatchTypeHeader5),
            @"^######(?:[^#]+)" : @(RFMarkdownRegexMatchTypeHeader6),

            @"\\s\\s\\s\\s(?:.+)" : @(RFMarkdownRegexMatchTypeCode),
            @"`(?:.+)`" : @(RFMarkdownRegexMatchTypeCode),
            @">+(?:.+)" : @(RFMarkdownRegexMatchTypeBlockQuote),
            
            @"(\\[\\w+(\\s\\w+)*\\]\\(\\w+\\w[/[\\.,-\\/#!?@$%\\^&\\*;:|{}<>+=\\-'_~()\\\"\\[\\]\\\\]/ \\w+]*\\))" : @(RFMarkdownRegexMatchTypeLink)
        };
        
        _markdownRegularExpressionsToType = [NSMutableDictionary dictionaryWithCapacity:[markdownRegularExpressionsStringsToType count]];
        for (NSString *regularExpressionString in markdownRegularExpressionsStringsToType) {
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularExpressionString options:0 error:nil];
            _markdownRegularExpressionsToType[regex] = markdownRegularExpressionsStringsToType[regularExpressionString];
        }
    }
    return self;
}

-(NSArray *) markdownTokensForString:(NSString*)markdownString searchRange:(NSRange)searchRange
{
    if (searchRange.length == 0) {
        return nil;
    }
    
    NSMutableArray *matches = [NSMutableArray array];
    NSArray *lines = [markdownString componentsSeparatedByString:@"\n"];
    NSInteger lineOffsetFromOriginal = 0;
    for (NSString *line in lines) {
        
        for (NSRegularExpression *regularExpression in _markdownRegularExpressionsToType) {
            [regularExpression enumerateMatchesInString:line
                                                options:0
                                                  range:NSMakeRange(0, [line length])
                                             usingBlock:^(NSTextCheckingResult *matchResult, NSMatchingFlags flags, BOOL *stop) {
                                                 NSRange matchRange = NSMakeRange(lineOffsetFromOriginal+matchResult.range.location, matchResult.range.length);
                                                 RFMarkdownRegexMatchType matchType = [_markdownRegularExpressionsToType[regularExpression] integerValue];
                                                 RFMarkdownRegexMatch *match = [[RFMarkdownRegexMatch alloc] init];
                                                 match.matchRange = matchRange;
                                                 match.matchType = matchType;
                                                 match.stripAllOtherAttributes = [self shouldStripAllOtherAttributesWithType:matchType];
                                                 [matches addObject:match];
                                             }];
        }
        
        lineOffsetFromOriginal += [line length]+1;
    }
    return matches;
}

-(BOOL) shouldStripAllOtherAttributesWithType:(RFMarkdownRegexMatchType)matchType
{
    switch (matchType) {
        case RFMarkdownRegexMatchTypeCode: return YES;
        default:
            break;
    }
    return NO;
}

@end
