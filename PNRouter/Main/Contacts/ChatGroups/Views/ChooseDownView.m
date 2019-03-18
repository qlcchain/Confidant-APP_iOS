//
//  ChooseDownView.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/25.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "ChooseDownView.h"

@implementation ChooseDownView

- (void)awakeFromNib {
    [super awakeFromNib];
    _confirmBackView.layer.cornerRadius = 3.0f;
    _confirmBackView.layer.masksToBounds = YES;
}

+ (instancetype) loadChooseDownView {
    ChooseDownView *view = [[[NSBundle mainBundle] loadNibNamed:@"ChooseDownView" owner:self options:nil] lastObject];
    return view;
}

@end
