//
//  EmailOptionCell.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/16.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *EmailOptionCellResue = @"EmailOptionCell";
#define EmailOptionCellHeight 60

@interface EmailOptionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *lblName;

@end

NS_ASSUME_NONNULL_END
