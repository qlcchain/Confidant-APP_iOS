//
//  ChooseCircleCell.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/27.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "ChooseCircleCell.h"
#import "RouterModel.h"
#import "PNDefaultHeaderView.h"

@implementation ChooseCircleShowModel

@end

@implementation ChooseCircleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _headImgView.layer.cornerRadius = _headImgView.width/2.0;
    _headImgView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
 
    _lblName.text = nil;
}

- (void)configCellWithModel:(ChooseCircleShowModel *)model {
    _lblName.text = model.routerM.name;
    NSString *userKey = @"";
    UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:_lblName.text]];
        _headImgView.image = defaultImg;
    
    BOOL isConnectRouter = NO;
    RouterModel *connectRouteM = [RouterModel getConnectRouter];
    if ([model.routerM.userSn isEqualToString:connectRouteM.userSn]) { // 当前连接路由
        isConnectRouter = YES;
    }
    _connectIcon.hidden = !isConnectRouter;
    if (model.showSelect && !isConnectRouter) {
        _leftContraintW.constant = 38;
    } else {
        _leftContraintW.constant = 0;
    }
    if (model.isSelect) {
        _selectImgView.image = [UIImage imageNamed:@"icon_selectmsg"];
    } else {
        _selectImgView.image = [UIImage imageNamed:@"icon_unselectmsg"];
    }
}

- (IBAction)selectAction:(id)sender {
    if (_selectB) {
        _selectB(_tableRow);
    }
}


@end
