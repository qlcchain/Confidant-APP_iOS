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
#import "PNDefaultHeaderView.h"
#import <YBImageBrowser/YBImageBrowser.h>

@implementation MyHeadView

+ (instancetype) loadMyHeadView {
    MyHeadView *headView = [[[NSBundle mainBundle] loadNibNamed:@"MyHeadView" owner:self options:nil] lastObject];
    headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 96);
    headView.HeanBtn.layer.cornerRadius = 24;
    headView.HeanBtn.layer.masksToBounds = YES;
    headView.HeanBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    return headView;
}

- (void) setUserNameFirstWithName:(NSString *)userName userKey:(NSString *)userKey {
    if (![UserModel getUserModel].headBaseStr || !_isMyHead) {
//        NSString *userKey = [EntryModel getShareObject].signPublicKey;
        UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:userName];
        [_HeanBtn setImage:defaultImg forState:UIControlStateNormal];
    } else {
        [_HeanBtn setImage:[UIImage imageWithData:[UserModel getUserModel].headBaseStr.base64DecodedData] forState:UIControlStateNormal];
    }
    
}

- (IBAction)headAction:(id)sender {
    // 本地图片（推荐使用 YBImage）
    YBImageBrowseCellData *data1 = [YBImageBrowseCellData new];
    UIImage *resultImg = _HeanBtn.currentImage;
    data1.imageBlock = ^__kindof UIImage * _Nullable{
        return resultImg;
    };
    data1.sourceObject = _HeanBtn.imageView;
    
    // 设置数据源数组并展示
    YBImageBrowser *browser = [YBImageBrowser new];
    browser.dataSourceArray = @[data1];
    browser.currentIndex = 0;
    [browser show];
    
}


@end
