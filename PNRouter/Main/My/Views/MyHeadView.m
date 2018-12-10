//
//  MyHeadView.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/10.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "MyHeadView.h"
#import "UserModel.h"
#import "NSString+Base64.h"

@implementation MyHeadView
+ (instancetype) loadMyHeadView
{
    MyHeadView *headView = [[[NSBundle mainBundle] loadNibNamed:@"MyHeadView" owner:self options:nil] lastObject];
    headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 135);
    headView.HeanBtn.layer.cornerRadius = 24;
    headView.HeanBtn.layer.masksToBounds = YES;
    headView.HeanBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    return headView;
}

- (void) setUserNameFirstWithName:(NSString *) userName
{
    if (![UserModel getUserModel].headBaseStr || !_isMyHead) {
        [_HeanBtn setTitle:userName forState:UIControlStateNormal];
    } else {
        [_HeanBtn setTitle:@"" forState:UIControlStateNormal];
        [_HeanBtn setImage:[UIImage imageWithData:[UserModel getUserModel].headBaseStr.base64DecodedData] forState:UIControlStateNormal];
    }
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
