//
//  SendFileHeadView.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/4/4.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "SendFileHeadView.h"

@implementation SendFileHeadView
+ (instancetype) getSendFileHeadView
{
    SendFileHeadView *headView = [[[NSBundle mainBundle] loadNibNamed:@"SendFileHeadView" owner:self options:nil] lastObject];
    return headView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
