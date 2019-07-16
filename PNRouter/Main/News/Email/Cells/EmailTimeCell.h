//
//  EmailTimeCell.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/12.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *EmailTimeCellResue = @"EmailTimeCell";
#define EmailTimeCellHeight 33
@interface EmailTimeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblTime;

@end

NS_ASSUME_NONNULL_END
