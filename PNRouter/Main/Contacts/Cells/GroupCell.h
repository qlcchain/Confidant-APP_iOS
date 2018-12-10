//
//  GroupCell.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/11.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *GroupCellReuse = @"GroupCell";
#define GroupCellHeight 47

@interface GroupCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIView *hdBackView;

@end
