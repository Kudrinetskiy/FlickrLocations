//
//  YKDetailViewController.m
//  Lesson4
//
//  Created by admin on 14.09.14.
//  Copyright (c) 2014 Yuri Kudrinetskiy. All rights reserved.
//

#import "YKDetailViewController.h"
#import "YKViewController.h"

@interface YKDetailViewController ()

@end

@implementation YKDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageView.alpha = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithFrame:self.view.frame];
    self.spinner.hidesWhenStopped = YES;
    self.spinner.color = [UIColor blueColor];
    [self.spinner startAnimating];
    [self.view addSubview:self.spinner];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = 0;
    }];
}

#pragma mark - YKViewController delegate

- (void)addYKViewController:(YKViewController *)controller didGetImage:(UIImage *)image description:(NSString *)description
{
    [self.spinner stopAnimating];
    self.imageView.image = image;
    self.navigationItem.title = description;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.imageView.alpha = 1;
    }];
}

@end
