//
//  EmoticonCell.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/5/30.
//  Copyright © 2019 旷自辉. All rights reserved.
//



#import "EmoticonCell.h"

#define IMG_WIDTH 31.0

@implementation EmojBtn
- (CGRect)imageRectForContentRect:(CGRect)bounds{
    return CGRectMake((self.size.width-IMG_WIDTH)/2,(self.size.height-IMG_WIDTH)/2, IMG_WIDTH, IMG_WIDTH);
}
@end

@implementation EmoticonCell
//用纯代码创建的时候走的创建方法
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self cellInit];
    }
    
    return self;
}

//用xib或者storyboard创建的时候走的创建方法
-(void)awakeFromNib
{
    [self cellInit];
    [super awakeFromNib];
}


-(void)cellInit
{
    //初始化按钮
    self.emoticonButton = [EmojBtn buttonWithType:UIButtonTypeCustom];
    
    //设置大小
    //self.emoticonButton.frame = CGRectMake(0, 0, 30, 30);
    //self.emoticonButton.center = self.contentView.center;
   
    self.emoticonButton.frame = self.bounds;

    
    //注册回调方法
    [self.emoticonButton addTarget:self action:@selector(emoticonButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.emoticonButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    //添加button
    [self.contentView addSubview:self.emoticonButton];
    
}

/**
 *  按钮被点击的时候，对父控件进行回调
 */
-(void)emoticonButtonClick:(UIButton *) sender
{
    //如果自己的回调被赋值后，才进行回调
    if (_clickCellB) {
        _clickCellB(sender.tag);
    }
}

@end
