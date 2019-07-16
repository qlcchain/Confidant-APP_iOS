//
//  EmailUserCell.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/12.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *EmailUserCellResue = @"EmailUserCell";
#define EmailUserCellHeight 37
@class EmailUserModel;
@interface EmailUserCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblType;

- (void) setUserModel:(EmailUserModel *) model;

@end

NS_ASSUME_NONNULL_END
