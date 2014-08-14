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
    
    UIFont* bodyFont = [UIFont systemFontOfSize:15.];
    UIFont* boldFont = [UIFont boldSystemFontOfSize:15.];
    UIFont* italicsFont = [UIFont italicSystemFontOfSize:15.];
    UIFont* boldItalicsFont = [UIFont italicSystemFontOfSize:16.];
    
    UIFont* headerOneFont = [UIFont systemFontOfSize:22.];
    UIFont* headerTwoFont = [UIFont systemFontOfSize:21.];
    UIFont* headerThreeFont = [UIFont systemFontOfSize:20.];
    UIFont* headerFourFont = [UIFont systemFontOfSize:19.];
    UIFont* headerFiveFont = [UIFont systemFontOfSize:18.];
    UIFont* headerSixFont = [UIFont systemFontOfSize:17.];
    
    RFMarkdownSyntaxStorage *syntaxStorage = [[RFMarkdownSyntaxStorage alloc] initWithBodyFont:bodyFont
                                                                                    bodyColour:[UIColor blackColor]
                                                                                    linkColour:[UIColor blueColor]
                                                                                      boldFont:boldFont
                                                                                   italicsFont:italicsFont
                                                                               boldItalicsFont:boldItalicsFont
                                                                                 headerOneFont:headerOneFont
                                                                                 headerTwoFont:headerTwoFont
                                                                               headerThreeFont:headerThreeFont
                                                                                headerFourFont:headerFourFont
                                                                                headerFiveFont:headerFiveFont
                                                                                 headerSixFont:headerSixFont];
                                              
    
    _textView = [[RFMarkdownTextView alloc] initWithFrame:self.view.bounds syntaxStorage:syntaxStorage];
    
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
