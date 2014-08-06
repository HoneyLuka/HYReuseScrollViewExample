//
//  MyView.h
//  ScrollViewTest
//
//  Created by xuyouchun on 14-8-5.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "HYReuseScrollView.h"

@interface MyView : HYReuseView

@property (nonatomic, strong) UILabel *label;

- (void)setText:(NSString *)str;

@end
