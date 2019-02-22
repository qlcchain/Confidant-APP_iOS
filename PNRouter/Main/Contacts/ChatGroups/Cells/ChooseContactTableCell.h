//
//  ContactTableCell.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/2/21.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ChooseContactRouterModel;

static NSString *ChooseContactTableCellResue = @"ChooseContactTableCell";
#define ChooseContactTableCellHeight 48

//typedef void(^ChooseContactChatBlock)(ChooseContactRouterModel *crModel);

@interface ChooseContactTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftContraintW;
@property (weak, nonatomic) IBOutlet UIImageView *selectImgView;

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
//@property (weak, nonatomic) IBOutlet UIButton *chatBtn;
//@property (nonatomic, copy) ChooseContactChatBlock contactChatB;

- (void)configCellWithModel:(ChooseContactRouterModel *)model;

@end

NS_ASSUME_NONNULL_END
