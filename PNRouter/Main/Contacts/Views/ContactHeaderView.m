//
//  UploadFilesHeaderView.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "ContactHeaderView.h"
#import "ContactShowModel.h"
#import "NSString+Base64.h"
#import "PNDefaultHeaderView.h"

@interface ContactHeaderView ()

@end

@implementation ContactHeaderView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _headImgView.layer.cornerRadius = _headImgView.width/2.0;
    _headImgView.layer.masksToBounds = YES;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _lblName.text = nil;
//    _lblTitle.text = nil;
    _arrowImg.image = nil;
    
}

- (void)configHeaderWithModel:(ContactShowModel *)model {
    
    NSString *name = [model.Name base64DecodedString]?:model.Name;
    if (model.Remarks && model.Remarks.length > 0) {
        name = [model.Remarks base64DecodedString]?:model.Remarks;
    }
    NSString *routerName = [model.RouteName base64DecodedString]?:model.RouteName;
    _lblName.text = model.showArrow?[NSString stringWithFormat:@"%@(%@)",name,@(model.routerArr.count)]:name;
    _lblRouterName.text = model.showArrow? @"": [NSString stringWithFormat:@"- %@",routerName?:@""];
    NSString *userKey = model.UserKey;
    UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:_lblName.text]];
    _headImgView.image = defaultImg;
//    _lblTitle.text = [StringUtil getUserNameFirstWithName:_lblName.text];
    _arrowImg.hidden = !model.showArrow;
    _arrowImg.image = model.showCell?[UIImage imageNamed:@"tabbar_arrow_upper"]:[UIImage imageNamed:@"tabbar_arrow_lower"];
   __block NSString *emailName = @"";
    if (model.showArrow) {
        [model.routerArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ContactRouterModel *contactM = obj;
            if (contactM.Mails && contactM.Mails.length > 0) {
                NSArray *emails =  [contactM.Mails componentsSeparatedByString:@","];
                emailName = [emails[0] base64DecodedString];
                *stop = YES;
            }
        }];
    } else {
        if (model.Mails && model.Mails.length > 0) {
            NSArray *emails =  [model.Mails componentsSeparatedByString:@","];
            emailName = [emails[0] base64DecodedString];
        }
    }
    _lblEmailName.text = emailName;
//    _selectBtn.selected = model.isSelect;
//    _selectImg.hidden = !_selectBtn.selected;
}

- (IBAction)selectAction:(UIButton *)sender {
//    if (_selectB) {
//        _selectB(_headerSection);
//    }
}

- (IBAction)showCellAction:(UIButton *)sender {
    if (_showCellB) {
        _showCellB(_headerSection);
    }
}


@end
