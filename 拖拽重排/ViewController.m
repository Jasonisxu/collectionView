//
//  ViewController.m
//  拖拽重排
//
//  Created by Wicrenet_Jason on 2017/6/20.
//  Copyright © 2017年 Wicrenet_Jason. All rights reserved.
//

#import "ViewController.h"
#import "ReleasePhotoCollectionViewCell.h"

#define SCREEN_HEIGHT   [[UIScreen mainScreen] bounds].size.height
#define SCREEN_WIDTH    [[UIScreen mainScreen] bounds].size.width
@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate>
@property (nonatomic ,strong) UICollectionView *centerCollectionView;
@property (nonatomic ,strong) NSMutableArray *photoArray;//只能选择9张照片的字典

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.photoArray = [NSMutableArray arrayWithObjects:
                       [UIImage imageNamed:@"a1"],
                       [UIImage imageNamed:@"a2"],
                       [UIImage imageNamed:@"a3"],
                       [UIImage imageNamed:@"a4"],
                       [UIImage imageNamed:@"a5"],
                       [UIImage imageNamed:@"a6"],
                       [UIImage imageNamed:@"a7"],
                       [UIImage imageNamed:@"a10"],
                       nil];
    [self addcollectionViewAction];
    [self setUpLongPressGes];
}

#pragma mark 添加collectionView
- (void)addcollectionViewAction {
    /**
     *
     http://www.jianshu.com/p/16c9d466f88c
     *
     http://www.cocoachina.com/bbs/read.php?tid=327440&page=1#1411664
     **/
    
    
    /**
     *http://www.cnblogs.com/leo-92/p/4311379.html
     *iOS UICollectionView 缝隙修复
     */
    
    //    NSLog(@"%f",SCREEN_WIDTH + pointX * 2);
    
    //1.初始化layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //横向滑动
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    //最小行边距
    layout.minimumLineSpacing = 10;
    //最小列边距
    layout.minimumInteritemSpacing = 10;
    //分区 上下左右的缩进距离(内边距)
    layout.sectionInset = UIEdgeInsetsMake(10, 0, 10, 0);


    //2.初始化collectionView
    self.centerCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 100, SCREEN_WIDTH, 120) collectionViewLayout:layout];
    self.centerCollectionView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.centerCollectionView];
    
    //3.注册collectionViewCell
    //注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
    [self.centerCollectionView registerNib:[UINib nibWithNibName:@"ReleasePhotoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"ReleasePhotoCollectionViewCell"];
    
    //4.设置代理
    self.centerCollectionView.delegate = self;
    self.centerCollectionView.dataSource = self;
    
}

#pragma mark collectionView代理方法
//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString *TaggedID=@"ReleasePhotoCollectionViewCell";
    ReleasePhotoCollectionViewCell *cell = (ReleasePhotoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:TaggedID forIndexPath:indexPath];
    
    UIImage *image = self.photoArray[indexPath.row];
    [cell.imagePhoto setImage:image];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return  CGSizeMake(100, 100);
}

//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"row:%li",indexPath.row);
}

#pragma mark --UICollectionView的拖拽重排--
//添加长按手势
- (void)setUpLongPressGes {
    UILongPressGestureRecognizer *longPresssGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressMethod:)];
    [self.centerCollectionView addGestureRecognizer:longPresssGes];
}

- (void)longPressMethod:(UILongPressGestureRecognizer *)longPressGes {
    CGPoint translatedPoint = [longPressGes locationInView:self.centerCollectionView];

    // 判断手势状态
    switch (longPressGes.state) {
            
        case UIGestureRecognizerStateBegan: {
            
            // 判断手势落点位置是否在路径上(长按cell时,显示对应cell的位置,如path = 1 - 0,即表示长按的是第1组第0个cell). 点击除了cell的其他地方皆显示为null
            NSIndexPath *indexPath = [self.centerCollectionView indexPathForItemAtPoint:[longPressGes locationInView:self.centerCollectionView]];
            // 如果点击的位置不是cell,break
            if (nil == indexPath) {
                break;
            }
            
            //最后一个不能移动
            if (indexPath.row == self.photoArray.count - 1) {
                break;
            }
            NSLog(@"%@",indexPath);

            // 在路径上则开始移动该路径上的cell
            [self.centerCollectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
            
        }
            break;
            
        case UIGestureRecognizerStateChanged: {
            //让cell只在collection里面移动
            if (translatedPoint.y != self.centerCollectionView.bounds.size.height/2) {
                translatedPoint.y = self.centerCollectionView.bounds.size.height/2;
            }
            
            NSLog(@"%.2f",self.centerCollectionView.contentSize.width);
            NSIndexPath *indexPath = [self.centerCollectionView indexPathForItemAtPoint:translatedPoint];
            //最后一个不能移动
            if (indexPath.row == self.photoArray.count - 1) {
                break;
            }

            // 移动过程当中随时更新cell位置
            [self.centerCollectionView updateInteractiveMovementTargetPosition:translatedPoint];
        }
            break;
            
        case UIGestureRecognizerStateEnded:
            // 移动结束后关闭cell移动
            [self.centerCollectionView endInteractiveMovement];
            break;
        default:
            [self.centerCollectionView cancelInteractiveMovement];
            break;
    }
}

//实现这个方法才能移动cell
- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    // 将数据插入到资源数组中的目标位置上
    [self.photoArray exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
