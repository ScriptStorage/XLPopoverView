//
//  ViewController.m
//  XLPopoverViewDemo
//
//  Created by mgfjx on 2017/9/4.
//  Copyright © 2017年 XXL. All rights reserved.
//

#import "ViewController.h"
#import "XLPopoverView.h"
#import "UIColor+Hex.h"

@interface ViewController ()<XLPopoverViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource> {
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(20, 20);
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    
    
    UICollectionView *collection = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
    collection.delegate   = self;
    collection.dataSource = self;
    [collection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    collection.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:collection];
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(btnClicked:)];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 44, 44);
    btn.backgroundColor = [UIColor randomColor];
    [btn setTitle:@"C" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor randomColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItems = @[item1, item2];
}
    
- (void)btnClicked:(UIView *)sender{
    
    NSArray *images = @[
                        @"bird73",@"carrot6",@"chat64",@"circle97",@"cloud289",
//                        @"earth199",@"eps13",@"fruit5",@"library17",@"library17",
//                        @"bird73",@"carrot6",@"chat64",@"circle97",@"cloud289",
                        ];
    NSArray *titles = @[
                        @"创建群聊",@"加好友/群",@"扫一扫",@"面对面快传",@"付款",
//                        @"拍摄",@"面对面红包",@"创建群聊/或搜索群/或搜索群",@"加好友/群",
//                        @"创建群聊",@"加好友/群",@"扫一扫",@"面对面快传",@"付款",
                        ];
    
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0 ; i < titles.count; i++) {
        XLPopoverCellModel *model = [XLPopoverCellModel modelWithImage:images[i] title:titles[i]];
        model.textColor = [UIColor redColor];
        [array addObject:model];
    }
    
    XLPopoverView *pop = [XLPopoverView popoverViewWithAttachmentView:sender images:images titles:titles];
//    pop.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    pop.delegate = self;
    pop.dataArray = [array copy];
    pop.showAnimation = YES;
    [pop show];
}

- (void)popoverView:(XLPopoverView * _Nonnull)popoverView index:(NSInteger)index {
    NSLog(@"%ld",index);
}

#pragma mark - UICollectionViewDelegate and UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 10000;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor randomColorWithAlpha:0.5];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self btnClicked:[collectionView cellForItemAtIndexPath:indexPath]];
}

@end
