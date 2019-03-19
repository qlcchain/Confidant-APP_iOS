//
//  UploadFilesHeaderView.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "ChooseContactHeaderView.h"
#import "ChooseContactShowModel.h"
#import "NSString+Base64.h"
#import "PNDefaultHeaderView.h"

@interface ChooseContactHeaderView ()

@end

@implementation ChooseContactHeaderView

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

- (void)configHeaderWithModel:(ChooseContactShowModel *)model {
    NSString *name = [model.Name base64DecodedString]?:model.Name;
    _lblName.text = model.showArrow?[NSString stringWithFormat:@"%@(%@)",name,@(model.routerArr.count)]:name;
    NSString *userKey = model.UserKey;
    UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:_lblName.text]];
    _headImgView.image = defaultImg;
//    _lblTitle.text = [StringUtil getUserNameFirstWithName:_lblName.text];
    _arrowImg.hidden = !model.showArrow;
    _arrowImg.image = model.showCell?[UIImage imageNamed:@"icon_arrow_down_gray"]:[UIImage imageNamed:@"icon_arrow_up_gray"];
    
    if (model.showSelect) {
        _leftContraintW.constant = 38;
    } else {
        _leftContraintW.constant = 0;
    }
    if (model.isSelect) {
        _selectImgView.image = [UIImage imageNamed:@"icon_selectmsg"];
    } else {
        _selectImgView.image = [UIImage imageNamed:@"icon_unselectmsg"];
    }
    _coverView.hidden = !model.userInterfaceOff;
    
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
