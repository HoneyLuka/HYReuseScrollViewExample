//
//  MyView.m
//  ScrollViewTest
//
//  Created by xuyouchun on 14-8-5.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "MyView.h"

@implementation MyView

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.label = [[UILabel alloc]initWithFrame:self.bounds];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont boldSystemFontOfSize:30.f];
        self.label.textColor = [UIColor whiteColor];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.label.backgroundColor = [UIColor clearColor];
        [self addSubview:self.label];
        self.label.text = @"unknown";
    }
    return self;
}

- (void)setText:(NSString *)str
{
    self.label.text = str;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
