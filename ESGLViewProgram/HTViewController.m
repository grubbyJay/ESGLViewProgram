//
//  HTViewController.m
//  ESGLViewProgram
//
//  Created by wb-shangguanhaitao on 14-2-13.
//  Copyright (c) 2014年 shangguan. All rights reserved.
//

#import "HTViewController.h"
#import "HTESGLView.h"

@interface HTViewController ()

@end

@implementation HTViewController

#pragma mark - Superclass API

- (void)loadView
{
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    self.view = [[HTESGLView alloc] initWithFrame:applicationFrame];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
