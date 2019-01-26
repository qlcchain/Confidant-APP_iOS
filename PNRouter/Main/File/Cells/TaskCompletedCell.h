//
//  TaskCompletedCell.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FileData;

NS_ASSUME_NONNULL_BEGIN

static NSString *TaskCompletedCellReuse = @"TaskCompletedCell";
#define TaskCompletedCellHeight 64

@interface TaskCompletedCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblDesc;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UIImageView *fileImgView;

- (void) setFileModel:(FileData *) model;
@end

NS_ASSUME_NONNULL_END
