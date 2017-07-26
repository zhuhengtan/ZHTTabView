//
//  ZHTTabManager.h
//  Test
//
//  Created by admin on 2017/7/24.
//  Copyright © 2017年 zht. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height

@class ZHTTabView;

@protocol ZHTTabViewDelegate <NSObject>

@required

/**
 传入需要显示的viewControllers的数组
 */
- (NSUInteger)numberOfPagesInZHTTabView:(ZHTTabView *)tabView;
- (UIViewController *)pageViewControllerOfZHTTabView:(ZHTTabView *)tabView indexOfPagers:(NSUInteger)number;

@optional
/**
 切换到不同pager可执行的事件
 */
- (void)didSelectIndexOfPage:(NSUInteger)number;

@end

@interface ZHTTabView : UIView

@property (nonatomic, weak)id<ZHTTabViewDelegate>delegate;

/**
 滑动按钮的高度
 */
@property (nonatomic, assign) CGFloat heightForHead;

/**
 滑动按钮部分与主体的间隔高度（默认为0，颜色为白色不可设置，如需设置可自行添加一行View，设置其背景颜色）
 */
@property (nonatomic, assign) CGFloat heightForGap;

/**
 按钮字体颜色（如不设置默认：选中为红色；未选中为黑色）
 */
@property (nonatomic, strong) UIColor *textColorForStateNormal;
@property (nonatomic, strong) UIColor *textColorForStateSelected;

/**
 按钮背景色（如不设置默认：均为白色）
 */
@property (nonatomic, strong) UIColor *backgroundColorForStateNormal;
@property (nonatomic, strong) UIColor *backgroundColorForStateSelected;

/**
 按钮选中字体（如不设置，默认均为14号系统thin字体）
 */
@property (nonatomic, assign) UIFont *fontForStateNormal;
@property (nonatomic, assign) UIFont *fontForStateSelected;

/**
 前边距宽度
 */
@property (nonatomic, assign) CGFloat widthForMargin;


/**
 分割线高度是头部高度的白分比（0～1），默认为0.5
 */
@property (nonatomic, assign) CGFloat ratioOfHeadHeight;
/**
 分割线宽度、颜色（如不设置默认为0、黑色）
 */
@property (nonatomic, assign) CGFloat widthForSeparatorLine;
@property (nonatomic, strong) UIColor *colorForSeparatorLine;

/**
 选中下划线宽度、颜色（如不设置默认为0、黑色）
 */
@property (nonatomic, assign) CGFloat heightForUnderLine;
@property (nonatomic, assign) CGFloat widthForUnderLine;
@property (nonatomic, strong) UIColor *colorForUnderLine;

#warning 先初始化然后自定义一些参数，然后调用这个方法。
-(void)startBuildingUI;

- (void)didSelectPageOfIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)showRedDotWithIndex:(NSUInteger)index;
- (void)hideRedDotWithIndex:(NSUInteger)index;

@end



#pragma mark UIView ZHTAdditions

@interface UIView (ZHTAdditions)

@property (assign, nonatomic) CGFloat x;
@property (assign, nonatomic) CGFloat y;
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (assign, nonatomic) CGSize size;
@property (assign, nonatomic) CGPoint origin;

@end
