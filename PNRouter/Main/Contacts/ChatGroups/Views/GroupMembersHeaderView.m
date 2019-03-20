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
#import "FriendModel.h"

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
    _detailLab.text = [model.Type integerValue] == 0?@"Group Owner":nil;
//    NSString *showName = model.Remarks&&model.Remarks.length>0?model.Remarks:model.Nickname;
    NSString *name = [model.showName base64DecodedString]?:model.showName;
    _nameLab.text = name;
    NSString *userKey = model.UserKey;
//    NSString *userKey = [FriendModel getSignPublicKeyWithToxId:model.ToxId];
    UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:name]];
    _headImg.image = defaultImg;
}

@end
