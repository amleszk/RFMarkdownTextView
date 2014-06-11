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
    
    _textView = [[RFMarkdownTextView alloc] initWithFrame:self.view.bounds];
    
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

@end
