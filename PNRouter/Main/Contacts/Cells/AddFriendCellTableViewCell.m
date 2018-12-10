//
//  AddFriendCellTableViewCell.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/13.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "AddFriendCellTableViewCell.h"
#import "FriendModel.h"
#import "NSDate+Category.h"

@implementation AddFriendCellTableViewCell

- (IBAction)rightAction:(UIButton *)sender {
    if (self.rightBlcok) {
        self.rightBlcok(sender.tag, self.tag);
    }
}


- (void) setFriendModel:(FriendModel *) model{
    _lblName.text = model.username?:@"";
    _lblStatus.text = @"";
    _rightBackView.hidden = YES;
    if (model.dealStaus == 1) {
        _lblStatus.text = @"Accepted";
    } else if (model.dealStaus == 2) {
        _lblStatus.text = @"Declined";
    } else {
//        NSTimeInterval timeInterval = [model.bg_createTime doubleValue]/1000;
//        NSDate *createDate = [[NSDate alloc] initWithTimeIntervalSince1970:timeInterval];
//        [c]
//        if () {
//
//        }
        _rightBackView.hidden = NO;
    }
    _lblTitle.text = [StringUtil getUserNameFirstWithName:model.username];
}
@end
