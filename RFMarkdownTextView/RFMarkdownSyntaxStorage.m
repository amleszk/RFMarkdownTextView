//
//  RFMarkdownSyntaxStorage.m
//  RFMarkdownTextViewDemo
//
//  Created by Rudd Fawcett on 12/6/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import "RFMarkdownSyntaxStorage.h"

@interface RFMarkdownSyntaxStorage ()

@property (nonatomic, strong) NSMutableAttributedString *attributedString;
@property (nonatomic, strong) NSDictionary *attributeDictionary;

@end

@implementation RFMarkdownSyntaxStorage

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
                   headerSixFont:(UIFont*)headerSixFont
{
    if (self = [super init]) {
        
        _bodyAttributes =
        @{  NSFontAttributeName : bodyFont,
            NSForegroundColorAttributeName : bodyColour,
            NSStrikethroughStyleAttributeName : @0,
            NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone)
            };
        
        _boldAttributes = @{ NSFontAttributeName : boldFont };
        _italicAttributes = @{ NSFontAttributeName : italicsFont };
        _boldItalicAttributes = @{ NSFontAttributeName : boldItalicsFont };
        _codeAttributes = @{ NSForegroundColorAttributeName : [bodyColour colorWithAlphaComponent:0.5] };
        _strikeAttributes = @{ NSStrikethroughStyleAttributeName : @1 };
        _linkAttributes = @{ NSForegroundColorAttributeName : linkColour, NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)};
        
        _headerOneAttributes = @{ NSFontAttributeName : headerOneFont };
        _headerTwoAttributes = @{ NSFontAttributeName : headerTwoFont };
        _headerThreeAttributes = @{ NSFontAttributeName : headerThreeFont };
        _headerFourAttributes = @{ NSFontAttributeName : headerFourFont };
        _headerFiveAttributes = @{ NSFontAttributeName : headerFiveFont };
        _headerSixAttributes = @{ NSFontAttributeName : headerSixFont };
        
        _attributedString = [NSMutableAttributedString new];
        
        [self createHighlightPatterns];
    }
    return self;
}

#pragma mark - Concrete overrides

- (NSString *)string {
    return [_attributedString string];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)location effectiveRange:(NSRangePointer)range {
    return [_attributedString attributesAtIndex:location effectiveRange:range];
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString*)str {
    [self beginEditing];
    [_attributedString replaceCharactersInRange:range withString:str];
    [self edited:NSTextStorageEditedCharacters | NSTextStorageEditedAttributes range:range changeInLength:str.length - range.length];
    [self endEditing];
}

- (void)setAttributes:(NSDictionary*)attrs range:(NSRange)range {
    [self beginEditing];
    [_attributedString setAttributes:attrs range:range];
    [self edited:NSTextStorageEditedAttributes range:range changeInLength:0];
    [self endEditing];
}

#pragma mark - Additional Concrete overrides

- (void)processEditing {
    [self performReplacementsForRange:[self editedRange]];
    [super processEditing];
}

- (void)performReplacementsForRange:(NSRange)changedRange {
    NSRange extendedRange = NSUnionRange(changedRange, [[_attributedString string] lineRangeForRange:NSMakeRange(changedRange.location, 0)]);
    extendedRange = NSUnionRange(changedRange, [[_attributedString string] lineRangeForRange:NSMakeRange(NSMaxRange(changedRange), 0)]);
    
    [self applyStylesToRange:extendedRange];
}

- (void)createHighlightPatterns {
    
    /*
     NSDictionary *headerOneAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:14]};
     NSDictionary *headerTwoAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:13]};
     NSDictionary *headerThreeAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:12.5]};
     
     Alternate H1 with underline:
     
     NSDictionary *headerOneAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:14],NSUnderlineStyleAttributeName:[NSNumber numberWithInt:NSUnderlineStyleSingle], NSUnderlineColorAttributeName:[UIColor colorWithWhite:0.933 alpha:1.0]};
     
     Headers need to be worked on...
     
     @"(\\#\\w+(\\s\\w+)*\n)":headerOneAttributes,
     @"(\\##\\w+(\\s\\w+)*\n)":headerTwoAttributes,
     @"(\\###\\w+(\\s\\w+)*\n)":headerThreeAttributes
     
     */
    
    _attributeDictionary = @{
        @"[a-zA-Z0-9\t\n ./<>?;:\\\"'`!@#$%^&*()[]{}_+=|\\-]":_bodyAttributes,
        @"\\**(?:^|[^*])(\\*\\*(\\w+(\\s\\w+)*)\\*\\*)":_boldAttributes,
        @"\\**(?:^|[^*])(\\*(\\w+(\\s\\w+)*)\\*)":_italicAttributes,
        @"(\\*\\*\\*\\w+(\\s\\w+)*\\*\\*\\*)":_boldItalicAttributes,
        @"(~~\\w+(\\s\\w+)*~~)":_strikeAttributes,
        
        @"(######\\s\\w+(\\s\\w+)*\\n)":_headerSixAttributes,
        @"(#####\\s\\w+(\\s\\w+)*\\n)":_headerFiveAttributes,
        @"(####\\s\\w+(\\s\\w+)*\\n)":_headerFourAttributes,
        @"(###\\s\\w+(\\s\\w+)*\\n)":_headerThreeAttributes,
        @"(##\\s\\w+(\\s\\w+)*\\n)":_headerTwoAttributes,
        @"(#\\s\\w+(\\s\\w+)*\\n)":_headerOneAttributes,
        
        @"(`\\w+(\\s\\w+)*`)":_codeAttributes,
        @"(```\n([\\s\n\\d\\w[/[\\.,-\\/#!?@$%\\^&\\*;:|{}<>+=\\-'_~()\\\"\\[\\]\\\\]/]]*)\n```)":_codeAttributes,
        @"(\\[\\w+(\\s\\w+)*\\]\\(\\w+\\w[/[\\.,-\\/#!?@$%\\^&\\*;:|{}<>+=\\-'_~()\\\"\\[\\]\\\\]/ \\w+]*\\))":_linkAttributes
    };
}

- (void)update {
    [self createHighlightPatterns];
    
    [self addAttributes:_bodyAttributes range:NSMakeRange(0, self.length)];
    
    [self applyStylesToRange:NSMakeRange(0, self.length)];
}

- (void)applyStylesToRange:(NSRange)searchRange {
    for (NSString *key in _attributeDictionary) {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:key options:0 error:nil];
        
        NSDictionary *attributes = _attributeDictionary[key];
        
        [regex enumerateMatchesInString:[_attributedString string] options:0 range:searchRange
            usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
                NSRange matchRange = [match rangeAtIndex:1];
                [self addAttributes:attributes range:matchRange];
                
                if (NSMaxRange(matchRange)+1 < self.length) {
                     [self addAttributes:_bodyAttributes range:NSMakeRange(NSMaxRange(matchRange)+1, 1)];
                }
        }];
    }
}

@end
