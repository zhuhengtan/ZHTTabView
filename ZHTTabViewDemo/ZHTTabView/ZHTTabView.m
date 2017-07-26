//
//  ZHTTabManager.m
//  Test
//
//  Created by admin on 2017/7/24.
//  Copyright © 2017年 zht. All rights reserved.
//

#import "ZHTTabView.h"

#define kHeadBtnW 80.0f

@interface ZHTTabView () <UIScrollViewDelegate>

/**
 总页数
 */
@property (nonatomic, assign) NSUInteger numberOfPages;
/**
 滑动的按钮条
 */
@property (nonatomic, strong) UIScrollView *headScrollView;

@property (nonatomic, strong) NSMutableArray *headBtnsArray;
@property (nonatomic, strong) NSMutableArray *redDotsArray;

@property (nonatomic, strong) UIView *underLineView;
@property (nonatomic, assign) CGFloat offsetXOfUnderLineViewBeforeMoving;

@property (nonatomic, assign) NSInteger tagOfCurrentSelectedbtn;
/**
 主体界面
 */
@property (nonatomic, strong) UIScrollView *bodyScrollView;

@property (nonatomic, assign) BOOL UIHasBuilt;
@property (nonatomic, assign) BOOL isDragging;

@property (nonatomic, assign) CGFloat startOffsetX;
@property (nonatomic, assign) BOOL isEndDecelerating;

@property (nonatomic, assign) NSInteger indexDraggedTo;

@end

@implementation ZHTTabView

-(void)startBuildingUI{
    _UIHasBuilt = NO;
    _isDragging = NO;
    _isEndDecelerating = YES;
    _startOffsetX = 0;
    _indexDraggedTo = 0;
   
    for (int i = 0; i < self.numberOfPages; i++) {
        //ScrollView部分
        UIViewController* vc = [self.delegate pageViewControllerOfZHTTabView:self indexOfPagers:i];
        
        [self.bodyScrollView addSubview:vc.view];
        
        //head上按钮
        UIButton* itemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        CGFloat itemButtonWidth = kHeadBtnW;
        
        [itemButton setTitle:vc.title forState:UIControlStateNormal];
        
        [itemButton setFrame:CGRectMake(self.widthForMargin + itemButtonWidth* i + self.widthForSeparatorLine * i, 0, itemButtonWidth, self.heightForHead)];
        [itemButton.titleLabel setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
        [itemButton.titleLabel setFont:self.fontForStateNormal];
        
        [itemButton setTitleColor:self.textColorForStateNormal forState:UIControlStateNormal];
        [itemButton setTitleColor:self.textColorForStateSelected forState:UIControlStateSelected];
        
        [itemButton setBackgroundColor:self.backgroundColorForStateNormal];
        [itemButton addTarget:self action:@selector(didSelectHeadBtn:) forControlEvents:UIControlEventTouchUpInside];
        itemButton.tag = i;
        [self.headBtnsArray addObject:itemButton];
        [self.headScrollView addSubview:itemButton];
    
        //headBtn上的红点
        UIView *redDot = [[UIView alloc] initWithFrame:CGRectMake(itemButton.width / 2 + [self sizeOfAdjustedBtn:itemButton].width / 2 + 3, itemButton.height / 2 - [self sizeOfAdjustedBtn:itemButton].height / 2, 8, 8)];
        redDot.backgroundColor = [UIColor redColor];
        redDot.layer.cornerRadius = redDot.width/2.0f;
        redDot.layer.masksToBounds = YES;
        redDot.hidden = YES;
        [self.redDotsArray addObject:redDot];
        [itemButton addSubview:redDot];
    }
    
    for (int i = 0; i < self.numberOfPages - 1; i++) {
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(self.widthForMargin + kHeadBtnW * (i+1), 0, self.widthForSeparatorLine, self.heightForHead * self.ratioOfHeadHeight)];
        separatorView.centerY = self.headScrollView.centerY;
        separatorView.backgroundColor = self.colorForSeparatorLine;
        [self.headScrollView addSubview:separatorView];
    }
    
    //tabView
    [self addSubview:self.headScrollView];
    _UIHasBuilt = YES;
    
    [self setNeedsLayout];
}
- (CGSize)sizeOfAdjustedBtn:(UIButton *)sender {
    CGSize size = CGSizeZero;
    size = [sender.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: sender.titleLabel.font}];
    return size;
}

- (void)layoutSubviews {
    if (_UIHasBuilt) {
        self.headScrollView.frame = CGRectMake(0, 0, self.width, self.heightForHead);
        self.bodyScrollView.frame = CGRectMake(0, self.heightForHead + self.heightForGap, self.width, self.height - self.heightForHead - self.heightForGap);
        self.headScrollView.contentSize = CGSizeMake(kHeadBtnW * self.numberOfPages + self.widthForSeparatorLine * (self.numberOfPages - 1) + 2 * self.widthForMargin, self.heightForHead);
        self.bodyScrollView.contentSize = CGSizeMake(self.width * self.numberOfPages, self.heightForHead + self.heightForGap);
        for (int i = 0; i < [self.delegate numberOfPagesInZHTTabView:self]; i++) {
            UIViewController* vc = [self.delegate pageViewControllerOfZHTTabView:self indexOfPagers:i];
            vc.view.frame = CGRectMake(self.bodyScrollView.width * i, 0, self.bodyScrollView.width, self.bodyScrollView.height);
        }
    }
}

-(void)didSelectHeadBtn:(UIButton *)sender{
    [self didSelectPageOfIndex:sender.tag animated:YES];
}

-(void)didSelectPageOfIndex:(NSUInteger)index animated:(BOOL)animated{
    UIButton *preButton = self.headBtnsArray[self.tagOfCurrentSelectedbtn];
    preButton.selected = NO;
    [preButton.titleLabel setFont:self.fontForStateNormal];
    
    UIButton *currentButton = self.headBtnsArray[index];
    currentButton.selected = YES;
    [currentButton.titleLabel setFont:self.fontForStateSelected];
    
    _tagOfCurrentSelectedbtn = index;
    
    CGPoint point = self.headScrollView.contentOffset;
    if (currentButton.tag > preButton.tag) {
        point = CGPointMake(currentButton.x + kHeadBtnW > point.x + kScreenW ? (currentButton.x + kHeadBtnW - kScreenW) :point.x, 0);
    }else{
        point = CGPointMake(currentButton.x < point.x ? currentButton.x:point.x, 0);
    }
    [UIView animateWithDuration:0.2 animations:^{
        [self.headScrollView setContentOffset:point];
    }];
    
    void(^moveUnderLine)(void) = ^(void) {
        self.underLineView.centerX = currentButton.center.x;
        self.offsetXOfUnderLineViewBeforeMoving = self.underLineView.x;
    };
    //移动underLineView
    animated ? [UIView animateWithDuration:0.2 animations:^{moveUnderLine();}] : moveUnderLine();
    
    [self switchToIndex:index animate:animated];
    if ([self.delegate respondsToSelector:@selector(didSelectIndexOfPage:)]) {
        [self.delegate didSelectIndexOfPage:index];
    }
    [self hideRedDotWithIndex:index];

}

- (void)moveUnderLineViewByScrollWithOffsetX:(CGFloat)offsetX {
    CGFloat textGap = (self.width - self.widthForMargin * 2 - self.widthForUnderLine * self.numberOfPages) / (self.numberOfPages * 2);
    CGFloat speed = 50;
    //移动的距离
    CGFloat movedFloat = self.offsetXOfUnderLineViewBeforeMoving + (offsetX * (textGap + self.widthForSeparatorLine + self.underLineView.width + speed)) / [UIScreen mainScreen].bounds.size.width;
    //最大右移值
    CGFloat underLineViewRightBarrier = _offsetXOfUnderLineViewBeforeMoving + kHeadBtnW;
    //最大左移值
    CGFloat underLineViewLeftBarrier = _offsetXOfUnderLineViewBeforeMoving - kHeadBtnW;
    CGFloat underLineViewNewX = 0;
    
    //连续拖动时的处理
    BOOL isContinueDragging = NO;
    if (_indexDraggedTo > 1) {
        isContinueDragging = YES;
    }
    
    if (movedFloat > underLineViewRightBarrier && !isContinueDragging) {
        //右慢拖动设置拦截
        underLineViewNewX = underLineViewRightBarrier;
    } else if (movedFloat < underLineViewLeftBarrier && !isContinueDragging) {
        //左慢拖动设置的拦截
        underLineViewNewX = underLineViewLeftBarrier;
    } else {
        //连续拖动可能超过总长的情况需要拦截
        if (isContinueDragging) {
            if (movedFloat > self.width - (self.widthForMargin + textGap + self.underLineView.width)) {
                underLineViewNewX = self.width - (self.widthForMargin + textGap + self.underLineView.width);
            } else if (movedFloat < self.widthForMargin + textGap) {
                underLineViewNewX = self.widthForMargin + textGap;
            } else {
                underLineViewNewX = movedFloat;
            }
        } else {
            //无拦截移动
            underLineViewNewX = movedFloat;
        }
    }
    [self.underLineView setFrame:CGRectMake(underLineViewNewX, self.underLineView.frame.origin.y, self.underLineView.frame.size.width, self.underLineView.frame.size.height)];
    
}
/*!
 * @brief 红点
 */
- (void)showRedDotWithIndex:(NSUInteger)index {
    UIView* redDot = self.redDotsArray[index];
    redDot.hidden = NO;
}
- (void)hideRedDotWithIndex:(NSUInteger)index {
    UIView* redDot = self.redDotsArray[index];
    redDot.hidden = YES;
}

- (void)switchToIndex:(NSUInteger)index animate:(BOOL)isAnimate {
    [self.bodyScrollView setContentOffset:CGPointMake(index*self.width, 0) animated:isAnimate];
    _isDragging = NO;
}


#pragma mark - ScrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.bodyScrollView) {
        _indexDraggedTo += 1;
        if (_isEndDecelerating) {
            _startOffsetX = scrollView.contentOffset.x;
        }
        _isDragging = YES;
        _isEndDecelerating = NO;
    }
}
/*!
 * @brief 对拖动过程中的处理
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.bodyScrollView) {
        CGFloat movingOffsetX = scrollView.contentOffset.x - _startOffsetX;
        if (_isDragging) {
            //tab处理事件待完成
            [self moveUnderLineViewByScrollWithOffsetX:movingOffsetX];
        }
    }
}
/*!
 * @brief 手释放后pager归位后的处理
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.bodyScrollView) {
        [self didSelectPageOfIndex:(int)scrollView.contentOffset.x/self.bounds.size.width animated:YES];
        _isDragging = YES;
        _isEndDecelerating = YES;
        _indexDraggedTo = 0;
    }
}
/*!
 * @brief 自动停止
 */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView == self.bodyScrollView) {
        //tab处理事件待完成
        [self didSelectPageOfIndex:(int)scrollView.contentOffset.x/self.bounds.size.width animated:YES];
    }
}

#pragma mark ========懒加载默认设置=======
-(CGFloat)heightForHead{
    if (!_heightForHead) {
        self.heightForHead = 40;
    }
    return _heightForHead;
}

-(CGFloat)heightForGap{
    if (!_heightForGap) {
        self.heightForGap = 0;
    }
    return _heightForGap;
}

-(UIColor *)textColorForStateNormal{
    if (!_textColorForStateNormal) {
        self.textColorForStateNormal = [UIColor blackColor];
    }
    return _textColorForStateNormal;
}

-(UIColor *)textColorForStateSelected{
    if (!_textColorForStateSelected) {
        self.textColorForStateSelected = [UIColor redColor];
    }
    return _textColorForStateSelected;
}

-(UIColor *)backgroundColorForStateNormal{
    if (!_backgroundColorForStateNormal) {
        self.backgroundColorForStateNormal = [UIColor whiteColor];
    }
    return _backgroundColorForStateNormal;
}

-(UIColor *)backgroundColorForStateSelected{
    if (!_backgroundColorForStateSelected) {
        self.backgroundColorForStateSelected = [UIColor whiteColor];
    }
    return _backgroundColorForStateSelected;
}

-(UIFont *)fontForStateNormal{
    if (!_fontForStateNormal) {
        self.fontForStateNormal = [UIFont systemFontOfSize:14 weight:UIFontWeightThin];
    }
    return _fontForStateNormal;
}

-(UIFont *)fontForStateSelected{
    if (!_fontForStateSelected) {
        self.fontForStateSelected = [UIFont systemFontOfSize:14 weight:UIFontWeightThin];
    }
    return _fontForStateSelected;
}

-(CGFloat)widthForMargin{
    if (!_widthForMargin) {
        self.widthForMargin = kHeadBtnW * self.numberOfPages < kScreenW ? (kScreenW - kHeadBtnW * self.numberOfPages -self.widthForSeparatorLine * (self.numberOfPages - 1))/2 : 0;
    }
    return _widthForMargin;
}

-(CGFloat)ratioOfHeadHeight{
    if (!_ratioOfHeadHeight) {
        self.ratioOfHeadHeight = 0.5;
    }
    return _ratioOfHeadHeight;
}

-(CGFloat)widthForSeparatorLine{
    if (!_widthForSeparatorLine) {
        self.widthForSeparatorLine = 0;
    }
    return _widthForSeparatorLine;
}
-(UIColor *)colorForSeparatorLine{
    if (!_colorForSeparatorLine) {
        self.colorForSeparatorLine = [UIColor blackColor];
    }
    return _colorForSeparatorLine;
}

-(CGFloat)heightForUnderLine{
    if (!_heightForUnderLine) {
        self.heightForUnderLine = 0;
    }
    return _heightForUnderLine;
}

-(CGFloat)widthForUnderLine{
    if (!_widthForUnderLine) {
        self.widthForUnderLine = 40;
    }
    return _widthForUnderLine;
}

-(UIColor *)colorForUnderLine{
    if (!_colorForUnderLine) {
        self.colorForUnderLine = [UIColor blackColor];
    }
    return _colorForUnderLine;
}

-(NSMutableArray *)headBtnsArray{
    if (!_headBtnsArray) {
        self.headBtnsArray = [[NSMutableArray alloc] init];
    }
    return _headBtnsArray;
}

-(NSMutableArray *)redDotsArray{
    if (!_redDotsArray) {
        self.redDotsArray = [[NSMutableArray alloc] init];
    }
    return _redDotsArray;
}

-(UIView *)underLineView{
    if (!_underLineView) {
        self.underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.heightForHead-self.heightForUnderLine, self.widthForUnderLine, self.heightForUnderLine)];
        self.underLineView.backgroundColor = self.colorForUnderLine;
        [self.headScrollView addSubview:self.underLineView];
    }
    return _underLineView;
}

-(CGFloat)offsetXOfUnderLineViewBeforeMoving{
    if (!_offsetXOfUnderLineViewBeforeMoving) {
        self.offsetXOfUnderLineViewBeforeMoving = 0;
    }
    return _offsetXOfUnderLineViewBeforeMoving;
}

-(NSInteger)tagOfCurrentSelectedbtn{
    if (!_tagOfCurrentSelectedbtn) {
        self.tagOfCurrentSelectedbtn = 0;
    }
    return _tagOfCurrentSelectedbtn;
}

-(NSUInteger)numberOfPages{
    if (!_numberOfPages) {
        self.numberOfPages = [self.delegate numberOfPagesInZHTTabView:self];
    }
    return _numberOfPages;
}

-(UIScrollView *)headScrollView{
    if (!_headScrollView) {
        self.headScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.heightForHead)];
        self.headScrollView.delegate = self;
        self.headScrollView.userInteractionEnabled = YES;
        self.headScrollView.bounces = NO;
        self.headScrollView.showsHorizontalScrollIndicator = NO;
        self.headScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_headScrollView];
    }
    return _headScrollView;
}

- (UIScrollView*)bodyScrollView {
    if (!_bodyScrollView) {
        self.bodyScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.heightForHead + self.heightForGap, self.width, self.height - self.heightForHead - self.heightForGap)];
        self.bodyScrollView.delegate = self;
        self.bodyScrollView.pagingEnabled = YES;
        self.bodyScrollView.userInteractionEnabled = YES;
        self.bodyScrollView.bounces = NO;
        self.bodyScrollView.showsHorizontalScrollIndicator = NO;
        self.bodyScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.bodyScrollView];
    }
    return _bodyScrollView;
}

@end




#pragma mark UIView ZHTAdditions
@implementation UIView (ZHTAdditions)

- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setCenterX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerY
{
    return self.center.y;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size
{
    return self.frame.size;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)origin
{
    return self.frame.origin;
}

@end
