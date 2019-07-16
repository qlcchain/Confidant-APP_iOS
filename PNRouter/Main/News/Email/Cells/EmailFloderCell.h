//
//  EmailFloderCell.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/10.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *EmailFloderCellResue = @"EmailFloderCell";
#define EmailFloderCellHeight 56


@interface EmailFloderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UILabel *lblCount;

@end

NS_ASSUME_NONNULL_END
