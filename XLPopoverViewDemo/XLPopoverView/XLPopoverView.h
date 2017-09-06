//
//  XLPopoverView.h
//  Unity
//
//  Created by mgfjx on 2017/9/4.
//  Copyright © 2017年 XXL. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XLPopoverView;
@class XLPopoverCellModel;
@class XLPopoverCell;

@protocol XLPopoverViewDelegate <NSObject>

@optional
    - (void)popoverView:(XLPopoverView * _Nonnull)popoverView index:(NSInteger)index ;
    

@end

@interface XLPopoverView : UIView
    
@property (nonatomic, strong) UIView * _Nonnull attachmentView;
@property (nonatomic, weak) id<XLPopoverViewDelegate> _Nullable delegate;
@property (nonatomic, strong) NSArray<XLPopoverCellModel *> * _Nonnull dataArray;
@property (nonatomic, strong) UIColor * _Nullable popoverColor ;
@property (nonatomic, assign) BOOL showAnimation;

+ (instancetype _Nullable )popoverViewWithAttachmentView:(UIView *_Nonnull)attachmentView ;
- (void)show ;

@end

/* ------------------------------------------------------------------------------------------------ */

@interface XLPopoverCellModel : NSObject
    
@property (nonatomic, strong) NSString * _Nullable imageName ;
@property (nonatomic, strong) NSString * _Nonnull title ;
@property (nonatomic, strong) UIColor * _Nullable textColor;
    
+ (instancetype _Nonnull)modelWithImage:(NSString * _Nullable)imageName title:(NSString  * _Nonnull )title ;

@end

/* ------------------------------------------------------------------------------------------------ */

@interface XLPopoverCell : UITableViewCell
    
@property (nonatomic, strong) XLPopoverCellModel * _Nullable  model;

@end
