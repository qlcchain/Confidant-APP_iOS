//
//  ContactTableCell.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/2/21.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "ChooseContactTableCell.h"
#import "ChooseContactShowModel.h"
#import "NSString+Base64.h"

@interface ChooseContactTableCell ()

@property (nonatomic, strong) ChooseContactRouterModel *contactRouterM;

@end

@implementation ChooseContactTableCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _chatBtn.layer.cornerRadius = 4;
    _chatBtn.layer.masksToBounds = YES;
    _chatBtn.layer.borderColor = UIColorFromRGB(0x2c2c2c).CGColor;
    _chatBtn.layer.borderWidth = 0.5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _icon.image = nil;
    _nameLab.text = nil;
}

- (void)configCellWithModel:(ChooseContactRouterModel *)model {
    _contactRouterM = model;
    _icon.image = [UIImage imageNamed:@"icon_router_small"];
    _nameLab.text = [model.RouteName base64DecodedString];
}


- (IBAction)chatAction:(id)sender {
    if (_contactChatB) {
        _contactChatB(_contactRouterM);
    }
}

@end
