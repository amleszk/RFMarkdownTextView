//
//  RFMarkdownSyntaxStorage.m
//  RFMarkdownTextViewDemo
//
//  Created by Rudd Fawcett on 12/6/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import "RFMarkdownSyntaxStorage.h"
#import "RFMarkdownRegexMatcher.h"

@interface RFMarkdownSyntaxStorage ()

@property (nonatomic, strong) NSMutableAttributedString *attributedStringBackingStore;
@property (nonatomic, strong) NSDictionary *attributeDictionary;
@property (strong,nonatomic) RFMarkdownRegexMatcher *markdownRegexMatcher;

@end

@implementation RFMarkdownSyntaxStorage

-(instancetype) init
{
    if (self = [super init]) {
        
        _markdownRegexMatcher = [[RFMarkdownRegexMatcher alloc] init];
        _attributedStringBackingStore = [NSMutableAttributedString new];
        
    }
    return self;
}

#pragma mark - Concrete overrides

-(NSAttributedString *) attributedString {
    return _attributedStringBackingStore;
}

- (NSString *)string {
    return [_attributedStringBackingStore string];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range {
    return [_attributedStringBackingStore attributesAtIndex:location effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString*)str {
    [self beginEditing];
    [_attributedStringBackingStore replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedCharacters | NSTextStorageEditedAttributes range:range changeInLength:str.length - range.length];
    [self endEditing];
}

- (void)setAttributes:(NSDictionary*)attrs range:(NSRange)range {
    [self beginEditing];
    [_attributedStringBackingStore setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    [self endEditing];
}

#pragma mark - Additional Concrete overrides

- (void)processEditing {
    [self performReplacementsForRange:[self editedRange]];
    [super processEditing];
}

- (void)performReplacementsForRange:(NSRange)changedRange {
    NSRange extendedRange = NSUnionRange(changedRange, [[_attributedStringBackingStore string] lineRangeForRange:NSMakeRange(changedRange.location, 0)]);
    extendedRange = NSUnionRange(changedRange, [[_attributedStringBackingStore string] lineRangeForRange:NSMakeRange(NSMaxRange(changedRange), 0)]);
    
    [self applyStylesToRange:extendedRange];
}

- (void)updateHighlightPatterns {
    
    _attributeDictionary = @{
                             
        @(RFMarkdownRegexMatchTypeBold) : _boldAttributes ?: @{},
        @(RFMarkdownRegexMatchTypeItalics) : _italicAttributes ?: @{},
        @(RFMarkdownRegexMatchTypeBoldItalics) : _boldItalicAttributes ?: @{},
        @(RFMarkdownRegexMatchTypeStrike) : _strikeAttributes ?: @{},
        
        @(RFMarkdownRegexMatchTypeHeader6) : _headerSixAttributes ?: @{},
        @(RFMarkdownRegexMatchTypeHeader5) : _headerFiveAttributes ?: @{},
        @(RFMarkdownRegexMatchTypeHeader4) : _headerFourAttributes ?: @{},
        @(RFMarkdownRegexMatchTypeHeader3) : _headerThreeAttributes ?: @{},
        @(RFMarkdownRegexMatchTypeHeader2) : _headerTwoAttributes ?: @{},
        @(RFMarkdownRegexMatchTypeHeader1) : _headerOneAttributes ?: @{},
        
        @(RFMarkdownRegexMatchTypeCode) : _codeAttributes ?: @{},
        @(RFMarkdownRegexMatchTypeBlockQuote) : _blockQuoteAttributes ?: @{},
        @(RFMarkdownRegexMatchTypeLink) : _linkAttributes ?: @{}
    };
}

- (void)update {
    [self updateHighlightPatterns];
    
    [self addAttributes:_bodyAttributes range:NSMakeRange(0, self.length)];
    
    [self applyStylesToRange:NSMakeRange(0, self.length)];
}

- (void)applyStylesToRange:(NSRange)searchRange {
    
    NSArray *tokens = [_markdownRegexMatcher markdownTokensForString:[_attributedStringBackingStore string] searchRange:searchRange];
    for (RFMarkdownRegexMatch *match in tokens) {
        NSDictionary *attributes = _attributeDictionary[@(match.matchType)];
        if (match.stripAllOtherAttributes) {
            [self setAttributes:@{} range:match.matchRange];
        }
        if (attributes) {
            [self addAttributes:attributes range:match.matchRange];
            if (NSMaxRange(match.matchRange)+1 < self.length) {
                [self addAttributes:_bodyAttributes range:NSMakeRange(NSMaxRange(match.matchRange)+1, 1)];
            }
        }
    }
}

@end
