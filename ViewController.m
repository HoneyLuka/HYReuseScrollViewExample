//
//  ViewController.m
//  ScrollViewTest
//
//  Created by xuyouchun on 14-8-1.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "ViewController.h"
#import "HYReuseScrollView.h"
#import "MyView.h"

@interface ViewController () <HYReuseScrollViewDataSource, HYReuseScrollViewDelegate>

@property (nonatomic, strong) HYReuseScrollView *scrollView;

@end

@implementation ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView = [[HYReuseScrollView alloc]initWithFrame:self.view.bounds];
    self.scrollView.reuseDelegate = self;
    self.scrollView.reuseDataSource = self;
//    self.scrollView.pagingEnabled = YES;
    
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.scrollView];
    
    [self.scrollView reloadData];
}

- (HYReuseView *)scrollView:(HYReuseScrollView *)scrollView viewForItemAtIndex:(NSInteger)index
{
    static NSString *str = @"view";
    MyView *view = [scrollView dequeueReusableViewWithIdentifier:str];
    if (!view) {
        view = [[MyView alloc]initWithReuseIdentifier:str];
    }
    
    [view setText:[NSString stringWithFormat:@"%d", index]];
    
    int color = index % 4;
    switch (color) {
        case 0:
            view.backgroundColor = [UIColor blueColor];
            break;
        case 1:
            view.backgroundColor = [UIColor greenColor];
            break;
        case 2:
            view.backgroundColor = [UIColor orangeColor];
            break;
        default:
            view.backgroundColor = [UIColor blackColor];
            break;
    }
    return view;
}

- (NSInteger)numberOfItemsInScrollView:(HYReuseScrollView *)scrollView
{
    return 100;
}

- (UIEdgeInsets)scrollView:(HYReuseScrollView *)scrollView insetForForItemAtIndex:(NSInteger)index
{
    return UIEdgeInsetsMake(20, 10, 20, 10);
}

@end
