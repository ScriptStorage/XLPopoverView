//
//  XLPopoverView.m
//  Unity
//
//  Created by mgfjx on 2017/9/4.
//  Copyright © 2017年 XXL. All rights reserved.
//

#import "XLPopoverView.h"

static CGFloat widthScale = 0.4;
static CGFloat CellHeight = 44.0;
static CGFloat FontSize = 17.0;
static CGFloat offsetScale = 1.0/5;
static CGFloat offset = 10.0;
static CGFloat triangleOffset = 11.0;
static CGFloat CornerRadius = 5;
static CGFloat AnimateDuration = 0.25;

typedef NS_ENUM(NSInteger, XLPopoverDirection) {
    XLPopoverDirectionUp = 0,
    XLPopoverDirectionLeft,
    XLPopoverDirectionDown,
    XLPopoverDirectionRight
};

@interface XLPopoverView ()<UITableViewDelegate, UITableViewDataSource> {
    UIView *_backgroundView;
    UITableView *_tableView;
    CAShapeLayer *_triangleLayer;
    XLPopoverDirection _direction;
    CGPoint _arrowLocation;
}

@end

@implementation XLPopoverView
    
- (void)dealloc {
    NSLog(@"[%@ dealloc]", NSStringFromClass([self class]));
}
    
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initViews {
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.1];
    self.frame = [UIScreen mainScreen].bounds;
    
    UIView *bgView = [UIView new];
//    bgView.backgroundColor = [UIColor redColor];
    bgView.clipsToBounds = YES;
    [self addSubview:bgView];
    _backgroundView = bgView;
    
    UITableView *table = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    table.delegate = self;
    table.dataSource = self;
    table.layer.cornerRadius = CornerRadius;
    table.layer.masksToBounds = YES;
    table.showsVerticalScrollIndicator = NO;
    table.tableFooterView = [UIView new];
    table.bounces = NO;
    [bgView addSubview:table];
    
    _tableView = table;
    
    CAShapeLayer *shaperLayer = [CAShapeLayer layer];
    shaperLayer.fillColor = [UIColor whiteColor].CGColor;
    [bgView.layer addSublayer:shaperLayer];
    _triangleLayer = shaperLayer;
    
}

- (void)didMoveToSuperview {
    
    if (!self.superview) {
        return;
    }
    
//    NSLog(@"superView: %@, frame: %@, delegate: %@", self.superview, NSStringFromCGRect(_tableView.frame), self.delegate);
    
    CGFloat width = [self calculateWidth];
    CGFloat height = [self calculateHeight];
    CGPoint origin = [self calculateOrigin];
    
    CGRect frame = CGRectZero;
    frame.origin = origin;
    frame.size.width = width;
    frame.size.height = height;
    _backgroundView.frame = frame;
    
    CGFloat tableY = 0.0;
    switch (_direction) {
        case XLPopoverDirectionUp:
            tableY = offset;
            break;
            
        case XLPopoverDirectionDown:
            tableY = 0.0;
            break;
            
        default:
            break;
    }
    
    _tableView.frame = CGRectMake(0, tableY, width, height - offset);
    
    _triangleLayer.path = [self trianglePath].CGPath;
    
    if (self.popoverColor) {
        _tableView.backgroundColor = self.popoverColor;
    }
    
}
    
#pragma mark - 私有方法

// 计算tableview原点
- (CGPoint)calculateOrigin {
    // 计算点击触发的view 在当前view的坐标
    CGRect rect = [self.attachmentView convertRect:self.attachmentView.bounds toView:self];
    CGFloat upHeight = rect.origin.y;
    CGFloat downHeight = self.frame.size.height - CGRectGetMaxY(rect);
    
    CGFloat height = [self calculateHeight];
    CGFloat width = [self calculateWidth];
    
    CGPoint point = CGPointZero;
    if (upHeight > downHeight) {
        point = CGPointMake(CGRectGetMaxX(rect) - rect.size.width/2 - width/2, rect.origin.y - height);
        _direction = XLPopoverDirectionDown;
    }else{
        point = CGPointMake(CGRectGetMaxX(rect) - rect.size.width/2 - width/2, CGRectGetMaxY(rect));
        _direction = XLPopoverDirectionUp;
    }
    
    if (point.x < offset) {
        point.x = offset;
    }
    
    if (point.x > self.frame.size.width - offset - width) {
        point.x = self.frame.size.width - offset - width;
    }
    
    return point;
}

// 计算backgroundView高度
- (CGFloat)calculateHeight {
    
    // 计算点击触发的view 在当前view的坐标
    CGRect rect = [self.attachmentView convertRect:self.attachmentView.bounds toView:self];
    CGFloat upHeight = rect.origin.y;
    CGFloat downHeight = self.frame.size.height - CGRectGetMaxY(rect);
    
    // 比较cell高度之和与上下所剩高度，若满足则选择较大者，若不满足则设置_tableView的高度并让其可滑动
    CGFloat maxHeight = upHeight > downHeight ? upHeight : downHeight;
    CGFloat tableHeight = CellHeight * _dataArray.count;
    if (tableHeight > maxHeight - 2*offset) {
        tableHeight = maxHeight - 2*offset;
        _tableView.bounces = YES;
        // 防止遮挡status bar
        if (upHeight > downHeight) {
            tableHeight -= offset;
        }
    }
    
    tableHeight += offset;
    
    
    return tableHeight;
}
  
// 计算backgroundView宽度
- (CGFloat)calculateWidth {
    CGFloat width = 0;
    // 遍历并计算title最长的宽度
    for (XLPopoverCellModel *model in _dataArray) {
        CGFloat textWidth = [model.title boundingRectWithSize:CGSizeMake(999, CellHeight) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:FontSize]} context:nil].size.width;
        if (width < textWidth) {
            width = textWidth;
        }
    }
    
    // 设定一个最大宽度
    if (width/self.frame.size.width > widthScale) {
        width = CellHeight*(1 - 2*offsetScale) + 3*offset + self.frame.size.width*widthScale;
    }else if (width/self.frame.size.width < widthScale - 0.15) {
        width = CellHeight*(1 - 2*offsetScale) + 3*offset + self.frame.size.width*(widthScale - 0.15);
    }else{
        width += CellHeight*(1 - 2*offsetScale) + 3*offset ;
    }
    
    return width;
}

// 绘制三角形
- (UIBezierPath *)trianglePath {
    
    CGPoint point = CGPointZero;
    CGRect rect = [self.attachmentView convertRect:self.attachmentView.bounds toView:self];
    CGFloat upHeight = rect.origin.y;
    CGFloat downHeight = self.frame.size.height - CGRectGetMaxY(rect);
    
    
    CGPoint point1, point2;
    
    /*
    switch (_direction) {
        case XLPopoverDirectionUp:
        {
            point = CGPointMake(CGRectGetMaxX(rect) - rect.size.width/2, CGRectGetMaxY(rect));
            point1 = CGPointMake(point.x - triangleOffset, point.y + triangleOffset);
            point2 = CGPointMake(point.x + triangleOffset, point.y + triangleOffset);
        }
            break;
            
        case XLPopoverDirectionDown:
        {
            point = CGPointMake(CGRectGetMaxX(rect) - rect.size.width/2, CGRectGetMinY(rect));
            point1 = CGPointMake(point.x - triangleOffset, point.y - triangleOffset);
            point2 = CGPointMake(point.x + triangleOffset, point.y - triangleOffset);
        }
            break;
            
        case XLPopoverDirectionLeft:
        {
            point = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect) + rect.size.height/2);
            point1 = CGPointMake(point.x + triangleOffset, point.y - triangleOffset);
            point2 = CGPointMake(point.x + triangleOffset, point.y + triangleOffset);
        }
            break;
            
        case XLPopoverDirectionRight:
        {
            point = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect) + rect.size.height/2);
            point1 = CGPointMake(point.x - triangleOffset, point.y - triangleOffset);
            point2 = CGPointMake(point.x - triangleOffset, point.y + triangleOffset);
        }
            break;
            
        default:
            break;
    }
     */
    
    // 三角形方向，1为向上，-1未向下
    NSInteger direction = 1;
    if (upHeight > downHeight) {
        direction = -1;
        point = CGPointMake(CGRectGetMaxX(rect) - rect.size.width/2, CGRectGetMinY(rect));
    }else {
        point = CGPointMake(CGRectGetMaxX(rect) - rect.size.width/2, CGRectGetMaxY(rect));
    }
    
    
    if (point.x < 2*offset + 2*CornerRadius) {
        point.x = 2*offset + 2*CornerRadius;
    }
    
    if (point.x > self.frame.size.width - 2*offset - 2*CornerRadius) {
        point.x = self.frame.size.width - 2*offset - 2*CornerRadius;
    }
    
    point1 = CGPointMake(point.x - triangleOffset, point.y + direction*triangleOffset);
    point2 = CGPointMake(point.x + triangleOffset, point.y + direction*triangleOffset);
    
    
    point = [self.layer convertPoint:point toLayer:_backgroundView.layer];
    _arrowLocation = point;
    point1 = [self.layer convertPoint:point1 toLayer:_backgroundView.layer];
    point2 = [self.layer convertPoint:point2 toLayer:_backgroundView.layer];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:point];
    [path addLineToPoint:point1];
    [path addLineToPoint:point2];
    [path closePath];
    
    return path;
}
    
- (void)show {
    
    NSCAssert(self.attachmentView, @"XLPopoverView没有设置必要的attachmentView属性!");
    NSCAssert(self.dataArray, @"XLPopoverView没有设置必要的dataArray属性!");
    NSCAssert([self.attachmentView respondsToSelector:@selector(convertRect:toView:)], @"XLPopoverView的attachmentView不支持convertRect:toView:方法!可能是attachmentView不是UIView的子类!");
    
    UIView *rootView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
    [rootView addSubview:self];
    
    [self showPopoverView:YES complete:^{
        
    }];
}
    
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self dismissFromSuperView];
}
    
- (void)showPopoverView:(BOOL)isShowing complete:(void (^)())complete{
    
    UIView *animationView = _backgroundView;
    
    CGFloat scale = 0.01;
    
    CGFloat offsetX =  0.0;
    CGFloat offsetY =  0.0;
    
    // 计算偏移量
    if (_direction == XLPopoverDirectionUp) {
        offsetX = -(1 - scale)*(_tableView.frame.size.width/2 - _arrowLocation.x);
        offsetY = -(1 - scale)*animationView.frame.size.height/2;
    }else{
        offsetX = -(1 - scale)*(_tableView.frame.size.width/2 - _arrowLocation.x);
        offsetY = (1 - scale)*animationView.frame.size.height/2;
    }
    
//    NSLog(@"offsetX: %f, offsetY: %f", offsetX, offsetY);
    
    CGAffineTransform beginTransform = CGAffineTransformIdentity;
    CGAffineTransform endTransform = CGAffineTransformIdentity;
    CGFloat beginAlpha = 0.0;
    CGFloat endAlpha = 0.0;
    
    if (isShowing) {
        beginTransform = CGAffineTransformMake(scale, 0, 0, scale, offsetX, offsetY);
        endTransform = CGAffineTransformIdentity;
        beginAlpha = 0;
        endAlpha = 1.0;
    }else{
        beginTransform = animationView.transform;
        endTransform = CGAffineTransformMake(scale, 0, 0, scale, offsetX, offsetY);
        beginAlpha = animationView.alpha;
        endAlpha = .1;
    }
    
    // 动画由小变大
    animationView.transform = beginTransform;
    self.alpha = beginAlpha;
    
    [UIView animateWithDuration:AnimateDuration animations:^{
        self.alpha = endAlpha;
        animationView.transform = endTransform;
        
    } completion:^(BOOL finished) {
        if (complete) {
            complete();
        }
    }];
    
}
    
- (void)dismissFromSuperView {
    [self showPopoverView:NO complete:^{
        [self removeFromSuperview];
    }];
}
    
#pragma mark - UITableViewDelegate and UITableViewDataSource
    
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}
    
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CellHeight;
}
    
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"cell";
    XLPopoverCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[XLPopoverCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        [self setLastCellSeperatorToLeft:cell];
    }
    
    cell.model = _dataArray[indexPath.row];
    
    return cell;
}
    
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.delegate && [self.delegate respondsToSelector:@selector(popoverView:index:)]) {
        [self.delegate popoverView:self index:indexPath.row];
    }
    [self dismissFromSuperView];
}
    
-(void)setLastCellSeperatorToLeft:(UITableViewCell *)cell{
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]){
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
}

@end

/* ------------------------------------------------------------------------------------------------ */

@implementation XLPopoverCellModel

+ (instancetype)modelWithImage:(NSString * _Nullable)imageName title:(NSString  * _Nonnull )title {
    XLPopoverCellModel *model = [[XLPopoverCellModel alloc] init];
    model.imageName = imageName;
    model.title = title;
    return model;
}

@end

/* ------------------------------------------------------------------------------------------------ */

@interface XLPopoverCell () {
    UIImageView *_iconView ;
    UILabel *_titleLabel ;
}

@end

@implementation XLPopoverCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
//        imageView.backgroundColor = [UIColor randomColorWithAlpha:.4];
        [self.contentView addSubview:imageView];
        _iconView = imageView;
        
        UILabel *label = [[UILabel alloc] init];
//        label.backgroundColor = [UIColor randomColorWithAlpha:.4];
        label.font = [UIFont systemFontOfSize:FontSize];
        [self.contentView addSubview:label];
        _titleLabel = label;
    }
    return self;
}
    
- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    _iconView.frame = CGRectMake(offset, height*offsetScale, height*(1-2*offsetScale), height*(1-2*offsetScale));
    _titleLabel.frame = CGRectMake(CGRectGetMaxX(_iconView.frame) + offset, CGRectGetMinY(_iconView.frame), width - CGRectGetMaxX(_iconView.frame) - 2*offset, CGRectGetHeight(_iconView.frame));
    
}

- (void)setModel:(XLPopoverCellModel *)model{
    _model = model;
    _iconView.image = [UIImage imageNamed:_model.imageName];
    _titleLabel.text = _model.title;
    if (_model.textColor) {
        _titleLabel.textColor = _model.textColor;
    }
}

@end

