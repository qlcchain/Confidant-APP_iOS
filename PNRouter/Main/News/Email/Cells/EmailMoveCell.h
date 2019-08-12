//
//  EmailMoveCell.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/19.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *EmailMoveCellResue = @"EmailMoveCell";
#define EmailMoveCellHeight 56

@interface EmailMoveCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UIImageView *selImgView;

@end

NS_ASSUME_NONNULL_END
