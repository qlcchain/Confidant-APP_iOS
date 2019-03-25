//
//  MyCell.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/10.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *MyCellReuse = @"MyCell";
#define MyCellReuse_Height 47

@interface MyCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *rightJD;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconWidth;

@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UIButton *subBtn;
@property (weak, nonatomic) IBOutlet UILabel *lblSubContent;

@end
