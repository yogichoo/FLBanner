
//
//  FLBanner.m
//  FLProgram
//
//  Created by FL on 15/10/23.
//  Copyright (c) 2015年 FL. All rights reserved.
//

#import "FLBanner.h"

#import "UIImageView+WebCache.h"
#import "Masonry.h"

#define FLViewWidth(a) (a).frame.size.width
#define FLViewHeigth(a) (a).frame.size.height

#define PAGECONTROL_HEIGHT 10
#define PAGEINDICATOR_WIDTH 20

@interface FLBanner () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UICollectionViewFlowLayout *collectionVwLayout;
@property (strong, nonatomic) UICollectionView *collectionVw;
@property (strong, nonatomic) UIPageControl *pageCtl;
@property (assign, nonatomic) FLLBannerPageCtrollerPosition positon;                                              //pageCtl的位置，默认：FLLBannerPageCtrollerCenter

@property (strong, nonatomic) NSMutableArray *dataArray;                                    //图片URL数组

@property (strong, nonatomic) NSTimer *timer;                                               //定时器
@property (assign, nonatomic) CGFloat time;                                                 //定时器时间
@property (assign, nonatomic) BOOL isStartTimer;                                            //是否开始定时器
@property (assign, nonatomic) BOOL isRepeat;                                                //是否重复滚动

@property (copy, nonatomic) FLBannerBlock bannerBlock;
@property (assign, nonatomic) BOOL bannerBlockEnable;                                       //是否可点击图片实现自定义操作

@end

@implementation FLBanner

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

//懒加载
- (UICollectionView *)collectionVw {
    if (!_collectionVw) {
        _collectionVwLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionVwLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionVwLayout.minimumLineSpacing = 0;
        _collectionVwLayout.minimumInteritemSpacing = 0;
        _collectionVw = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:_collectionVwLayout];
        _collectionVw.pagingEnabled = YES;
        _collectionVw.showsHorizontalScrollIndicator = NO;
        _collectionVw.showsVerticalScrollIndicator = NO;
        _collectionVw.dataSource = self;
        _collectionVw.delegate = self;
        [_collectionVw registerClass:[FLBannerCell class] forCellWithReuseIdentifier:@"flBanner"];
    }
    return _collectionVw;
}

- (UIPageControl *)pageCtl {
    if (!_pageCtl) {
        _pageCtl = [[UIPageControl alloc] init];
        _pageCtl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageCtl.currentPageIndicatorTintColor = [UIColor whiteColor];
        //iOS14 后设置背景样式
        if (@available(iOS 14.0, *)) 
            _pageCtl.backgroundStyle = UIPageControlBackgroundStyleAutomatic;
        _pageCtl.enabled = NO;
        _pageCtl.currentPage = 0;
    }
    return _pageCtl;
}

#pragma mark - UI
//初始化视图
- (instancetype)init {
    self = [super init];
    if (self) {
        [self customUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self customUI];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    super.frame = frame;
    [self layoutWidth:FLViewWidth(self) height:FLViewHeigth(self)];
}

- (void)customUI {
    //如果是iOS11.0以下的版本需要关掉滚动视图的偏移
    //[FLHelper getCurrentViewController]：获取当前试图所在的试图控制器
    if ([[UIDevice currentDevice].systemVersion floatValue] < 11.0)
        [self getCurrentViewController].automaticallyAdjustsScrollViewInsets = NO;
    
    //默认重复滚动
    self.isRepeat = YES;
    //默认切换时间
    [self startTimer:3.0f];
    //默认pageCtl位置
    self.positon = FLLBannerPageCtrollerCenter;
    //添加视图
    [self addSubview:self.collectionVw];
    [self addSubview:self.pageCtl];
}

/**
 * 重点：必须调用此方法，否则UI会出现问题
 */
- (void)layoutWidth:(CGFloat)width height:(CGFloat)height {
    //重新布置视图大小
    /**
     * ！重点此处Banner视图宽度：防止pageCtl.currentPage无法对上，宽度加上对应长度
     */
    self.collectionVw.frame = CGRectMake(0, 0, width>375?(width+0.25):(width+0.5), height);
    self.collectionVwLayout.itemSize = CGSizeMake(width, height);
}

#pragma mark - About Data
//设置图片数据
- (void)refreshUI:(NSArray *)array action:(FLBannerBlock)block {
    /**
     *  图片数组,数据加载以及pageCtl相关设置
     */
    //设置图片数组
    if (array.count != 0) {
        //清空数组
        if (self.dataArray.count != 0)
            [self.dataArray removeAllObjects];
        
        //将数组中得数据赋予key,方便设置pageCtl.currentPage
        for (NSInteger i = 0; i<array.count ; i++) {
            NSMutableDictionary *imageDict = [[NSMutableDictionary alloc] init];
            [imageDict setValue:@(i) forKey:@"index"];
            [imageDict setValue:array[i] forKey:@"image"];
            [self.dataArray addObject:imageDict];
        }
        
        //当图片数组只有一个元素时，停止定时器并隐藏pageCtl
        if (self.dataArray.count == 1) {
            [self stopTimer];
            self.pageCtl.hidden = YES;
        }else {
            self.pageCtl.hidden = NO;
            //设置最大的图片的个数
            self.pageCtl.numberOfPages = self.dataArray.count;
            //设置pageCtl的位置
            if (@available(iOS 14.0, *)) {
                [self.pageCtl mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.centerX.equalTo(self);
                    make.bottom.offset(-10);
                    make.height.offset(PAGECONTROL_HEIGHT);
                }];
            }else{
                self.pageCtl.frame = CGRectMake(FLViewWidth(self.collectionVw)/2-(PAGEINDICATOR_WIDTH*self.dataArray.count/2), FLViewHeigth(self)-10-PAGECONTROL_HEIGHT, PAGEINDICATOR_WIDTH*self.dataArray.count, PAGECONTROL_HEIGHT);
            }
        }
        //刷新UI
        [self.collectionVw reloadData];
    }
    if (block) {
        self.bannerBlockEnable = YES;
        self.bannerBlock = block;
    }else {
        self.bannerBlockEnable = NO;
    }
}

#pragma mark - Timer
//启动定时器
-(void)startTimer:(NSTimeInterval)timeInterval {
    [self stopTimer];
    
    self.isStartTimer = YES;
    self.time = timeInterval;       //记录定时器切换时间
    //当self.timer == nil时，初始化定时器
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
        //防止定时器与主线程阻塞
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

- (void)timerAction {
    //当执行此代码时，第二张图片已经调到图片数组中第一个位置，偏移量也变为CGPointZero
    [self.collectionVw setContentOffset:CGPointMake(FLViewWidth(self)+0.5, 0) animated:YES];
}

//停止定时器 (释放定时器)
- (void)stopTimer {
    self.isStartTimer = NO;
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - Other Setting
//设置是否显示pageCtller
- (void)setPageCtlHidden:(BOOL)isHidden {
    self.pageCtl.hidden = isHidden;
}

- (void)setRepeatScroll:(BOOL)isRepeat {
    self.isRepeat = isRepeat;
    self.collectionVw.bounces = isRepeat;
}

#pragma mark - s
//主要逻辑
//只要有滚动，就会调整函数
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.dataArray.count != 0 ) {
        if (scrollView == self.collectionVw) {
            //不重复滚动时，self.collectionVw.bounces会被设置成NO，所以需要分开处理这两种情况
            if (self.isRepeat) {
                //向左滑动
                //当self.collectionVw.contentOffset.x > VIEW_WIDTH(self)，即indexPath.item=1的图片已经全部显示完
                if (self.collectionVw.contentOffset.x > FLViewWidth(self)) {
                    //先保存数组的第一张图片
                    id tempPic = [self.dataArray firstObject];
                    for (NSInteger i=0; i<self.dataArray.count; i++) {
                        //把数组中得元素向前移1位, 事先保存的第一张图片放到最后
                        if (i == self.dataArray.count -1)
                            self.dataArray[i] = tempPic;
                        else
                            self.dataArray[i] = self.dataArray[i+1];
                    }
                    //立即跳回第一页
                    self.collectionVw.contentOffset = CGPointZero;
                    //刷新UI
                    [self.collectionVw reloadData];
                }
                //向右滑动
                //当self.collectionVw.contentOffset.x < 0时，立即显示数组中得最后一张图片
                else if (self.collectionVw.contentOffset.x < 0) {
                    //先保存最后一张图片
                    id tempPic = [self.dataArray lastObject];
                    for (NSInteger i=self.dataArray.count-1; i>=0; i--) {
                        //把事先保存的最后一张图片，放到第一位
                        if (i == 0)
                            self.dataArray[i] = tempPic;
                        else
                            self.dataArray[i] = self.dataArray[i-1];    //元素全部往后移1位
                    }
                    //当self.collectionVw.contentOffset.x < 0时，立即跳到第二张图片显示的位置
                    //此时数组已经被修改该，CGPointMake(VIEW_WIDTH(self), 0)的图片已经被修改该成,数组修改后的self.dataArray[1];即被向后移了一位的1.jpg
                    self.collectionVw.contentOffset = CGPointMake(FLViewWidth(self)-0.25, 0);
                    //刷新UI
                    [self.collectionVw reloadData];
                }
                
                //设置pageCtl.currentPage
                NSDictionary *dict = [self.dataArray firstObject];
                self.pageCtl.currentPage = [dict[@"index"] integerValue];
            }else {
                //设置pageCtl.currentPage
                //此处+0.5，防止pageCtl.currentPage计算错误
                NSInteger index = (scrollView.contentOffset.x+0.5)/FLViewWidth(self.collectionVw);
                self.pageCtl.currentPage = index;
            }
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.isStartTimer)
        [self startTimer:self.time];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //防止手动滑动banner时，图片没有完全移动至顶边的问题
    //0.25是防止滑动幅度过大，导致pageCtl与图片不同步的问题
    CGPoint point = scrollView.contentOffset;
    if (point.x < FLViewWidth(self)/2 && point.x > 0)
        point.x = 0+0.25;
    else if (point.x > FLViewWidth(self)/2 && point.x < FLViewWidth(self))
        point.x = FLViewWidth(self)+0.25;
    [scrollView setContentOffset:point animated:YES];
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FLBannerCell *bannerCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"flBanner" forIndexPath:indexPath];
    [bannerCell refreshUI:self.dataArray[indexPath.item]];
    return bannerCell;
}
//点击事件
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.bannerBlockEnable)
        self.bannerBlock(self.pageCtl.currentPage);
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    //释放控制器
    [self stopTimer];
}

- (UIViewController *)getCurrentViewController {
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    //从根控制器开始查找
    UIViewController *rootVC = window.rootViewController;
    UIViewController *activityVC = nil;
    while (true) {
        if ([rootVC isKindOfClass:[UINavigationController class]])
            activityVC = [(UINavigationController *)rootVC visibleViewController];
        else if ([rootVC isKindOfClass:[UITabBarController class]])
            activityVC = [(UITabBarController *)rootVC selectedViewController];
        else if (rootVC.presentedViewController)
            activityVC = rootVC.presentedViewController;
        else
            break;
        rootVC = activityVC;
    }
    return activityVC;
}

@end



@interface FLBannerCell ()

@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation FLBannerCell

//懒加载
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_imageView];
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.right.mas_offset(0);
        }];
    }
    return _imageView;
}

- (void)refreshUI:(NSDictionary *)dict {
    if ([dict[@"image"] isKindOfClass:[NSString class]]) {
        if ([dict[@"image"] hasPrefix:@"http"])
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:dict[@"image"]]];
        else
            self.imageView.image = [UIImage imageNamed:dict[@"image"]];
    }else if ([dict[@"image"] isKindOfClass:[UIImage class]]) {
        self.imageView.image = dict[@"image"];
    }
}

@end
