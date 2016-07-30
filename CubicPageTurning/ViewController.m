//
//  ViewController.m
//  CubicPageTurning
//
//  Created by 万晓 on 16/7/24.
//  Copyright © 2016年 wxm. All rights reserved.
//

#import "ViewController.h"
#import "UIView+XMGExtension.h"

@interface ViewController ()<UIScrollViewDelegate>

//控制器翻页滚动视图
@property(nonatomic,strong) UIScrollView *scrollView;

//视图数组
@property(nonatomic,strong) NSArray *viewArray;

//当前页
@property(nonatomic,assign) NSInteger currentPage;

@end

@implementation ViewController

//3D透视函数
CATransform3D CATransform3DMakePerspective(CGPoint center, float disZ)
{
    CATransform3D transToCenter = CATransform3DMakeTranslation(-center.x, -center.y, 0);
    CATransform3D transBack = CATransform3DMakeTranslation(center.x, center.y, 0);
    CATransform3D scale = CATransform3DIdentity;
    scale.m34 = -1.0f/disZ;
    return CATransform3DConcat(CATransform3DConcat(transToCenter, scale), transBack);
}

CATransform3D CATransform3DPerspect(CATransform3D t, CGPoint center, float disZ)
{
    return CATransform3DConcat(t, CATransform3DMakePerspective(center, disZ));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //*******添加scrollView*******
    [self createScrollView];
    
    //******创建立方体视图组******
    [self createCubicViewArray];
}

#pragma mark - 添加scrollView
-(void)createScrollView{
    
    CGFloat contentW=4 * self.view.bounds.size.width;
    CGFloat contentH=self.view.bounds.size.height;
    
    //scrollView的尺寸占据整个屏幕（可实现透视效果）
    self.scrollView=[[UIScrollView alloc] initWithFrame:self.view.bounds];
    
    //内容物大小
    _scrollView.contentSize=CGSizeMake(contentW, contentH);
    _scrollView.bounces = NO;
    _scrollView.backgroundColor=[UIColor clearColor];
    
    _scrollView.pagingEnabled=YES;
    
    _scrollView.delegate=self;
    
    [self.view addSubview:_scrollView];
    
}

#pragma mark - 创建立方体视图组
-(void)createCubicViewArray{
    
    //创建子视图
    
    UIImageView *imageView1=[[UIImageView alloc] initWithFrame:self.view.frame];
    imageView1.image=[UIImage imageNamed:@"1.jpeg"];
    
    UIImageView *imageView2=[[UIImageView alloc] initWithFrame:self.view.frame];
    imageView2.image=[UIImage imageNamed:@"2.jpeg"];
    
    UIImageView *imageView3=[[UIImageView alloc] initWithFrame:self.view.frame];
    imageView3.image=[UIImage imageNamed:@"3.jpeg"];
    
    UIImageView *imageView4=[[UIImageView alloc] initWithFrame:self.view.frame];
    imageView4.image=[UIImage imageNamed:@"4.jpeg"];
    
    //添加各视图到scrollView上面
    [self.scrollView addSubview:imageView1];
    [self.scrollView addSubview:imageView2];
    [self.scrollView addSubview:imageView3];
    [self.scrollView addSubview:imageView4];
    
    self.viewArray=@[imageView1,imageView2,imageView3,imageView4];
    
    //添加视图到scrollView上
    for (int i=0; i<_viewArray.count; i++) {
        
        UIImageView *transView=_viewArray[i];
        
        //视图在scrollView上对应的位置
        transView.x=self.view.bounds.size.width * i;
    }
}

#pragma mark - scrollView滑动事件
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    //当前页数
    NSInteger currentPage=_currentPage;
    
    //当前视图
    UIView *currentView=_viewArray[currentPage];
    
    //上一个视图
    UIView *lastView=nil;
    
    if (currentPage-1>=0) {
        
        lastView=_viewArray[currentPage-1];
    }
    
    //下一个视图控制器视图
    UIView *nextView;
    
    if (currentPage+1<=3) {
        
        nextView=_viewArray[currentPage+1];
    }
    
    //本次偏移距离
    CGFloat currentOffset=scrollView.contentOffset.x-currentPage*self.view.bounds.size.width;
    
    //本次偏移角度
    CGFloat deltaAngle=currentOffset/self.view.bounds.size.width * M_PI_2;
    
    //****************当前视图移动变幻***************
    
    //设置锚点
    currentView.layer.anchorPoint=CGPointMake(0.5, 0.5);
    
    //向屏幕前方移动
    CATransform3D move = CATransform3DMakeTranslation(0, 0, self.view.bounds.size.width/2);
    
    //旋转
    CATransform3D rotate = CATransform3DMakeRotation(-deltaAngle, 0, 1, 0);
    
    //平移
    CATransform3D plaintMove=CATransform3DMakeTranslation( currentOffset, 0, 0);
    
    //向屏幕后方移动
    CATransform3D back = CATransform3DMakeTranslation(0, 0, -self.view.bounds.size.width/2);
    
    //连接
    CATransform3D concat=CATransform3DConcat( CATransform3DConcat(move, CATransform3DConcat(rotate, plaintMove)),back);
    
    CATransform3D transform=CATransform3DPerspect(concat, CGPointMake(currentOffset/2, self.view.bounds.size.height), 5000.0f);
    
    //添加变幻特效
    currentView.layer.transform=transform;
    
    //****************下一个视图移动变幻***************
    
    //设置锚点
    nextView.layer.anchorPoint=CGPointMake(0.5, 0.5);
    
    //向屏幕前方移动
    CATransform3D move2 = CATransform3DMakeTranslation(0, 0, self.view.bounds.size.width/2);
    
    //旋转
    CATransform3D rotate2 = CATransform3DMakeRotation(-deltaAngle+M_PI_2, 0, 1, 0);
    
    //平移
    CATransform3D plaintMove2=CATransform3DMakeTranslation( currentOffset-self.view.bounds.size.width, 0, 0);
    
    //向屏幕后方移动
    CATransform3D back2 = CATransform3DMakeTranslation(0, 0, -self.view.bounds.size.width/2);
    
    //拼接
    CATransform3D concat2=CATransform3DConcat( CATransform3DConcat(move2, CATransform3DConcat(rotate2, plaintMove2)),back2);
    
    CATransform3D transform2=CATransform3DPerspect(concat2, CGPointMake(self.view.bounds.size.width/2+currentOffset/2, self.view.bounds.size.height), 5000.0f);
    
    //添加变幻特效
    nextView.layer.transform=transform2;
    
    //****************上一个视图移动变幻***************
    
    //设置锚点
    lastView.layer.anchorPoint=CGPointMake(0.5, 0.5);
    
    //向屏幕前方移动
    CATransform3D move3 = CATransform3DMakeTranslation(0, 0, self.view.bounds.size.width/2);
    
    //旋转
    CATransform3D rotate3 = CATransform3DMakeRotation(-deltaAngle-M_PI_2, 0, 1, 0);
    
    //平移
    CATransform3D plaintMove3=CATransform3DMakeTranslation( currentOffset+self.view.bounds.size.width, 0, 0);
    
    //向屏幕后方移动
    CATransform3D back3 = CATransform3DMakeTranslation(0, 0, -self.view.bounds.size.width/2);
    
    //拼接
    CATransform3D concat3=CATransform3DConcat(CATransform3DConcat(move3, CATransform3DConcat(rotate3, plaintMove3)),back3);
    
    CATransform3D transform3=CATransform3DPerspect(concat3, CGPointMake(-self.view.bounds.size.width/2+currentOffset/2, self.view.bounds.size.height), 5000.0f);
    
    //添加变幻特效
    lastView.layer.transform=transform3;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    //改变选中页序号
    [self changeIndex];
    
    //3D变幻恢复原状态
    for (UIView * view in _viewArray) {
        
        view.layer.transform=CATransform3DIdentity;
    }
}

-(void)changeIndex{
    
    //改变选中的标签
    _currentPage=_scrollView.contentOffset.x/self.view.bounds.size.width;
}

@end
