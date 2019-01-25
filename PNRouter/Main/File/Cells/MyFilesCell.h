//
//  MyFilesCell.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *MyFilesCellReuse = @"MyFilesCell";
#define MyFilesCellHeight 64

@interface MyFilesCell : UITableViewCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectLeftWidth;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *detailLab;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;


@end

NS_ASSUME_NONNULL_END
