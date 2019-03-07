//
//  ChooseContactCell.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/25.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>
static NSString *ChooseContactCellReuse = @"ChooseContactCell";
#define ChooseContactCellHeight 56

#import "FriendModel.h"

@interface ChooseContactCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftContraintV;
@property (weak, nonatomic) IBOutlet UIImageView *selectImgView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImgV;
//@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;

- (void) setModeWithModel:(FriendModel *) model withLeftContraintV:(CGFloat) leftV;
@end
