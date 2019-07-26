//
//  EmailContactCell.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EmailContactModel;

NS_ASSUME_NONNULL_BEGIN

static NSString *EmailContactCellResue = @"EmailContactCell";
#define EmailContactCellHeight 64

@interface EmailContactCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImgV;
@property (weak, nonatomic) IBOutlet UILabel *lblSubContent;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UIImageView *selImgView;

- (void) setEmailContactModel:(EmailContactModel *) model;
@end

NS_ASSUME_NONNULL_END
