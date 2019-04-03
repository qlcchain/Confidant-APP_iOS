//
//  PNDefaultHeaderView.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/7.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNDefaultHeaderView.h"
#import "UIView+Screenshot.h"
#import "UserHeaderModel.h"
#import "NSData+Base64.h"

@interface PNDefaultHeaderView ()

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;

@end

@implementation PNDefaultHeaderView

+ (instancetype)loadView {
    PNDefaultHeaderView *view = [[[NSBundle mainBundle] loadNibNamed:@"PNDefaultHeaderView" owner:self options:nil] lastObject];
    return view;
}

+ (UIImage *)getImageWithUserkey:(NSString *)userKey Name:(NSString *)name backFrame:(CGRect)backFrame {
    UIImage *resultImg = nil;
    NSString *userHeaderImg64Str = [UserHeaderModel getUserHeaderImg64StrWithKey:userKey];
    if (userHeaderImg64Str) {
        resultImg = [UIImage imageWithData:[NSData dataWithBase64EncodedString:userHeaderImg64Str]];
    } else {
        PNDefaultHeaderView *view = [PNDefaultHeaderView loadView];
        view.frame = backFrame;
        view.nameLab.text = name;
        view.nameLab.font = [UIFont systemFontOfSize:18];
        resultImg = [view convertViewToImage];
    }
    return resultImg;
}

+ (UIImage *)getImageWithUserkey:(NSString *)userKey Name:(NSString *)name {
    UIImage *resultImg = nil;
    NSString *userHeaderImg64Str = [UserHeaderModel getUserHeaderImg64StrWithKey:userKey];
    if (userHeaderImg64Str) {
        resultImg = [UIImage imageWithData:[NSData dataWithBase64EncodedString:userHeaderImg64Str]];
    } else {
        PNDefaultHeaderView *view = [PNDefaultHeaderView loadView];
        view.nameLab.text = name;
        view.nameLab.font = [UIFont systemFontOfSize:18];
        resultImg = [view convertViewToImage];
    }
    return resultImg;
}

+ (UIImage *)getImageWithUserkey:(NSString *)userKey Name:(NSString *)name fontSize:(NSInteger)fontSize {
    UIImage *resultImg = nil;
    NSString *userHeaderImg64Str = [UserHeaderModel getUserHeaderImg64StrWithKey:userKey];
    if (userHeaderImg64Str) {
        resultImg = [UIImage imageWithData:[NSData dataWithBase64EncodedString:userHeaderImg64Str]];
    } else {
        PNDefaultHeaderView *view = [PNDefaultHeaderView loadView];
        view.nameLab.text = name;
        view.nameLab.font = [UIFont systemFontOfSize:fontSize];
        resultImg = [view convertViewToImage];
    }
    return resultImg;
}

@end
