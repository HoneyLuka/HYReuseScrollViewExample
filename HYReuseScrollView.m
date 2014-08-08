//
//  HYReuseScrollView.m
//  ScrollViewTest
//
//  Created by xuyouchun on 14-8-1.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "HYReuseScrollView.h"

#pragma mark - HYReuseView

@interface HYReuseView ()

@property (nonatomic, copy, readwrite) NSString *identifier;

@property (nonatomic, assign, readwrite) NSInteger index;

@end

@implementation HYReuseView

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"contentOffset" context:nil];
    [self removeObserver:self forKeyPath:@"frame" context:nil];
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super init];
    if (self) {
        if (reuseIdentifier) {
            self.identifier = reuseIdentifier;
        }
    }
    return self;
}

@end

#pragma mark - HYReuseScrollView

@interface HYReuseScrollView () <UIScrollViewDelegate>

@property (nonatomic, assign) NSInteger currentIndex;

/**
 [
     view, view;
 ]
 */
@property (nonatomic, strong) NSMutableArray *visibleViews;

/**
 {
     "reuseId": reuseSet;
 }
 */
@property (nonatomic, strong) NSMutableDictionary *reuseViews;

@end

@implementation HYReuseScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - Instance Method

- (id)dequeueReusableViewWithIdentifier:(NSString *)identifier
{
    if (![[self.reuseViews allKeys]containsObject:identifier]) {
        return nil;
    }
    
    NSMutableSet *set = self.reuseViews[identifier];
    
    id reuseView = [set anyObject];
    
    if (reuseView) {
        [set removeObject:reuseView];
    }
    
    return reuseView;
}

- (void)reloadData
{
    [self resetScrollViewContentSize];
    [self reuseAllView];
    [self refreshView];
}

#pragma mark - Reuse Method

- (void)reuseViewIfNeeded
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    for (int i = 0; i < self.visibleViews.count; i++) {
        HYReuseView *view = self.visibleViews[i];
        if ([self checkIfViewNeedReuse:view]) {
            [self reuseViewIntoSet:view];
            [indexSet addIndex:i];
        }
    }
    
    if (indexSet.count) {
        [self.visibleViews removeObjectsAtIndexes:indexSet];
    }
}

- (void)reuseAllView
{
    for (HYReuseView *view in self.visibleViews) {
        [self reuseViewIntoSet:view];
    }
    [self.visibleViews removeAllObjects];
}

- (void)reuseViewIntoSet:(HYReuseView *)view
{
    if (view.superview) {
        [view removeFromSuperview];
    }
    
    if ([[self.reuseViews allKeys]containsObject:view.identifier]) {
        NSMutableSet *set = self.reuseViews[view.identifier];
        [set addObject:view];
    } else {
        NSMutableSet *set = [NSMutableSet set];
        [set addObject:view];
        [self.reuseViews setObject:set forKey:view.identifier];
    }
}

- (BOOL)checkIfViewNeedReuse:(HYReuseView *)view
{
    NSInteger indexOffset = view.index - self.currentIndex;
    indexOffset = indexOffset < 0 ? indexOffset * -1 : indexOffset;
    
    if (indexOffset > self.preloadNum) {
        return YES;
    }
    return NO;
}

#pragma mark - Reset Method

- (void)loadNearbyView
{
    NSInteger beginIndex = self.currentIndex - self.preloadNum;
    beginIndex = beginIndex < 0 ? 0 : beginIndex;
    
    NSInteger endIndex = self.currentIndex + self.preloadNum;
    NSInteger itemCount = [self numberOfItems];
    endIndex = endIndex >= itemCount ? itemCount - 1 : endIndex;
    
    for (NSInteger i = beginIndex; i <= endIndex; i++) {
        int hasFound = NO;
        for (HYReuseView *view in self.visibleViews) {
            if (view.index == i) {
                hasFound = YES;
                break;
            }
        }
        
        if (!hasFound) {
            [self addViewToIndex:i];
        }
    }
}

- (void)refreshView
{
    NSInteger beginIndex = self.currentIndex - self.preloadNum;
    beginIndex = beginIndex < 0 ? 0 : beginIndex;
    
    NSInteger endIndex = self.currentIndex + self.preloadNum;
    NSInteger itemCount = [self numberOfItems];
    endIndex = endIndex >= itemCount ? itemCount - 1 : endIndex;
    
    for (NSInteger i = beginIndex; i <= endIndex; i++) {
        [self addViewToIndex:i];
    }
}

- (HYReuseView *)addViewToIndex:(NSInteger)index
{
    HYReuseView *view = [self.reuseDataSource scrollView:self viewForItemAtIndex:index];
    view.index = index;
    
    UIEdgeInsets inset = [self insetForIndex:index];
    
    view.frame = CGRectMake(CGRectGetWidth(self.bounds) * index + inset.left,
                            inset.top,
                            CGRectGetWidth(self.bounds) - inset.right - inset.left,
                            CGRectGetHeight(self.bounds) - inset.bottom - inset.top);
    [self addSubview:view];
    
    [self.visibleViews addObject:view];
    
    return view;
}

#pragma mark - Utility Method

- (void)resetScrollViewContentSize
{
    NSInteger count = [self numberOfItems];
    self.contentSize = CGSizeMake(CGRectGetWidth(self.bounds) * count, CGRectGetHeight(self.bounds));
}

- (NSInteger)numberOfItems
{
    if (self.reuseDataSource
        && [self.reuseDataSource respondsToSelector:@selector(numberOfItemsInScrollView:)]) {
        return [self.reuseDataSource numberOfItemsInScrollView:self];
    }
    
    return 0;
}

- (UIEdgeInsets)insetForIndex:(NSInteger)index
{
    if (self.reuseDelegate
        && [self.reuseDelegate respondsToSelector:@selector(scrollView:insetForForItemAtIndex:)]) {
        return [self.reuseDelegate scrollView:self insetForForItemAtIndex:index];
    }
    return self.reuseViewInset;
}

#pragma mark Target/Action

- (void)scrollViewDidScrollWithOffset:(CGPoint)offset
{
    NSInteger index = offset.x / CGRectGetWidth(self.bounds);
    if (index < 0) {
        index = 0;
    }
    
    NSInteger itemCount = [self numberOfItems];
    if (index >= itemCount) {
        index = itemCount - 1;
    }
    
    if (self.currentIndex != index) {
        self.currentIndex = index;
        [self reuseViewIfNeeded];
        [self loadNearbyView];
    }

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint offset = [change[NSKeyValueChangeNewKey]CGPointValue];
        [self scrollViewDidScrollWithOffset:offset];
    } else if ([keyPath isEqualToString:@"frame"]) {
        [self reloadData];
    }
}

#pragma mark - Init Method

- (void)setup
{
    self.visibleViews = [NSMutableArray array];
    self.reuseViews = [NSMutableDictionary dictionary];
    
    self.reuseViewInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.preloadNum = 2;
    
    [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
}

@end
