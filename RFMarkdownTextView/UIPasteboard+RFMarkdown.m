//
//  UIPasteboard+RFMarkdown.m
//  RFMarkdownTextViewDemo
//
//  Created by al on 8/06/2014.
//  Copyright (c) 2014 Rex Finn. All rights reserved.
//

#import "UIPasteboard+RFMarkdown.h"

@implementation UIPasteboard (RFMarkdown)

-(NSString *) validURLString
{
    NSString *pasteboardString = [self string];
    NSString *validURLString;
    if ([NSURL URLWithString:pasteboardString]) {
        validURLString = pasteboardString;
    }
    return validURLString;
}

@end
