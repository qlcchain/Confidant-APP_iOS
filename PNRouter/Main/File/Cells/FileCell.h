//
//  FileCell.h
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/11.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

//#import <SWTableViewCell/SWTableViewCell.h>
#import <UIKit/UIKit.h>

@class OperationRecordModel;

static NSString *FileCellReuse = @"FileCell";
#define FileCellHeight 64

typedef void(^FileMoreBlock)(void);

//@interface FileCell : SWTableViewCell
@interface FileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UIImageView *operationIcon;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLab;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
@property (nonatomic, copy) FileMoreBlock fileMoreB;

- (void)configCellWithModel:(OperationRecordModel *)model;

@end
