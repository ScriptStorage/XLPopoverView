//
//  ViewController.m
//  XLPopoverViewDemo
//
//  Created by mgfjx on 2017/9/4.
//  Copyright © 2017年 XXL. All rights reserved.
//

#import "ViewController.h"
#import "XLPopoverView.h"

@interface ViewController ()<XLPopoverViewDelegate> {
    UIButton *_btn;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(300, 300, 20, 20);
    [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor cyanColor];
    
    [self.view addSubview:btn];
    
    _btn = btn;
    
}
    
- (void)btnClicked:(UIView *)sender{
    
    NSArray *images = @[
                        @"bird73",@"carrot6",@"chat64",@"circle97",@"cloud289",
                        @"earth199",@"eps13",@"fruit5",@"library17",@"library17",
                        @"bird73",@"carrot6",@"chat64",@"circle97",@"cloud289",
                        ];
    NSArray *titles = @[
                        @"创建群聊",@"加好友/群",@"扫一扫",@"面对面快传",@"付款",
                        @"拍摄",@"面对面红包",@"创建群聊/或搜索群/或搜索群",@"加好友/群",
                        @"创建群聊",@"加好友/群",@"扫一扫",@"面对面快传",@"付款",
                        ];
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0 ; i < titles.count; i++) {
        [array addObject:[XLPopoverCellModel modelWithImage:images[i] title:titles[i]]];
    }
    
    XLPopoverView *pop = [[XLPopoverView alloc] initWithFrame:self.view.bounds];
    pop.delegate = self;
    pop.attachmentView = sender;
    pop.dataArray = [array copy];
    [pop show];
}

- (void)popoverView:(XLPopoverView * _Nonnull)popoverView index:(NSInteger)index {
    NSLog(@"%ld",index);
}

@end
