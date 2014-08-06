//
//  HYReuseScrollView.h
//  ScrollViewTest
//
//  Created by xuyouchun on 14-8-1.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - HYReuseView

@interface HYReuseView : UIView

@property (nonatomic, copy, readonly) NSString *identifier;

@property (nonatomic, assign, readonly) NSInteger index;

/**
 初始化用这个.
 */
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end

#pragma mark - HYReuseScrollView

@class HYReuseScrollView;

@protocol HYReuseScrollViewDelegate <NSObject>

@optional

/**
 获取对应下标的偏移量(可以用来做间隔).
 */
- (UIEdgeInsets)scrollView:(HYReuseScrollView *)scrollView insetForForItemAtIndex:(NSInteger)index;

@end

@protocol HYReuseScrollViewDataSource <NSObject>

@required

/**
 一共有几个元素.
 */
- (NSInteger)numberOfItemsInScrollView:(HYReuseScrollView *)scrollView;

/**
 获取对应下标的view.
 */
- (HYReuseView *)scrollView:(HYReuseScrollView *)scrollView viewForItemAtIndex:(NSInteger)index;

@end

@interface HYReuseScrollView : UIScrollView

/**
 如果直接设置这个属性, 则所有reuseView的inset都一致.
 想要单独设置某个view的inset可以使用HYReuseScrollViewDelegate协议内的方法.
 */
@property (nonatomic, assign) UIEdgeInsets reuseViewInset;

/**
 前后保留的页数, 默认是2.(前后各会保留preloadNum个view)
 */
@property (nonatomic, assign) NSInteger preloadNum;

@property (nonatomic, weak) id<HYReuseScrollViewDelegate> reuseDelegate;
@property (nonatomic, weak) id<HYReuseScrollViewDataSource> reuseDataSource;

/**
 根据identifier尝试获取可重用的view. (参照UITableView的用法)
 */
- (id)dequeueReusableViewWithIdentifier:(NSString *)identifier;

/**
 初始化用这个.
 */
- (id)initWithFrame:(CGRect)frame;

/**
 刷新数据
 */
- (void)reloadData;

@end
