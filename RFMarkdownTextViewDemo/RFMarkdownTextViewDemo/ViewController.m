//
//  ViewController.m
//  RFMarkdownTextViewDemo
//
//  Created by Rudd Fawcett on 12/1/13.
//  Copyright (c) 2013 Rudd Fawcett. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) RFMarkdownTextView *textView;

@end

@implementation ViewController

- (void)viewDidLoad  {
    [super viewDidLoad];
    
    self.title = @"RFMarkdownTextView";
    
    RFMarkdownSyntaxStorage *syntaxStorage = [[RFMarkdownSyntaxStorage alloc] init];
    UIFont* bodyFont = [UIFont fontWithName:@"Verdana" size:15.];
    UIFont* boldFont = [UIFont fontWithName:@"Verdana-Bold" size:15.];
    UIFont* italicsFont = [UIFont fontWithName:@"Verdana-Italic" size:15.];
    UIFont* boldItalicsFont = [UIFont fontWithName:@"Verdana-BoldItalic" size:15.];

    syntaxStorage.bodyAttributes =
    @{  NSFontAttributeName : bodyFont,
        NSForegroundColorAttributeName : [UIColor blackColor],
        NSStrikethroughStyleAttributeName : @0,
        NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone),
        NSBackgroundColorAttributeName : [UIColor clearColor]
    };

    syntaxStorage.boldAttributes = @{ NSFontAttributeName : boldFont };
    syntaxStorage.italicAttributes = @{ NSFontAttributeName : italicsFont };
    syntaxStorage.boldItalicAttributes = @{ NSFontAttributeName : boldItalicsFont };
    syntaxStorage.codeAttributes = @{
        NSFontAttributeName : [UIFont fontWithName:@"Courier New" size:15.],
        NSForegroundColorAttributeName : [[UIColor blackColor] colorWithAlphaComponent:0.5]
    };
    syntaxStorage.strikeAttributes = @{ NSStrikethroughStyleAttributeName : @1 };
    syntaxStorage.linkAttributes = @{ NSForegroundColorAttributeName : [[UIColor blueColor] colorWithAlphaComponent:0.7], NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)};
    syntaxStorage.blockQuoteAttributes = @{ NSBackgroundColorAttributeName : [[UIColor blueColor] colorWithAlphaComponent:0.2]};

    syntaxStorage.headerOneAttributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:22.] };
    syntaxStorage.headerTwoAttributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:21.] };
    syntaxStorage.headerThreeAttributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:20.] };
    syntaxStorage.headerFourAttributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:19.] };
    syntaxStorage.headerFiveAttributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:18.] };
    syntaxStorage.headerSixAttributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:17.] };
    [syntaxStorage updateHighlightPatterns];
    
    _textView = [[RFMarkdownTextView alloc] initWithFrame:self.view.bounds syntaxStorage:syntaxStorage];
    _textView.toolbarEnabled = YES;
    
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                       target:self
                                                       action:@selector(resetText)];

    
    [self.view addSubview:_textView];
}

-(void) resetText
{
    _textView.text = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [_textView becomeFirstResponder];
}

@end
