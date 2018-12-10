//
//  ShareCollectionCell.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/10.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "ShareCollectionCell.h"

@implementation ShareCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _backView.layer.cornerRadius = 8;
    _backView.layer.masksToBounds = YES;
}

@end
