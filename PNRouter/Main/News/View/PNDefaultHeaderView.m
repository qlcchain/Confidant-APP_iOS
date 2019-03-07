//
//  PNDefaultHeaderView.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/7.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNDefaultHeaderView.h"
#import "UIView+Screenshot.h"

@interface PNDefaultHeaderView ()

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;

@end

@implementation PNDefaultHeaderView

+ (instancetype)loadView {
    PNDefaultHeaderView *view = [[[NSBundle mainBundle] loadNibNamed:@"PNDefaultHeaderView" owner:self options:nil] lastObject];
    return view;
}

+ (UIImage *)getImageWithName:(NSString *)name {
    PNDefaultHeaderView *view = [PNDefaultHeaderView loadView];
    view.nameLab.text = name;
    UIImage *img = [view convertViewToImage];
    
    return img;
}


@end
