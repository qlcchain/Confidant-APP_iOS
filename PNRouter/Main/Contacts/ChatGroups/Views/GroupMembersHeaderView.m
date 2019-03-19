//
//  UploadFilesHeaderView.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "GroupMembersHeaderView.h"
#import "GroupMembersModel.h"
#import "NSString+Base64.h"
#import "PNDefaultHeaderView.h"

@interface GroupMembersHeaderView ()

@end

@implementation GroupMembersHeaderView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _headImg.layer.cornerRadius = _headImg.width/2.0;
    _headImg.layer.masksToBounds = YES;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _nameLab.text = nil;
    _detailLab.text = nil;
    
}

- (void)configHeaderWithModel:(GroupMembersModel *)model {
//    NSString *name = [model.Name base64DecodedString]?:model.Name;
//    _lblName.text = model.showArrow?[NSString stringWithFormat:@"%@(%@)",name,@(model.routerArr.count)]:name;
//    NSString *userKey = model.UserKey;
//    UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:_lblName.text]];
//    _headImg.image = defaultImg;
}

@end
