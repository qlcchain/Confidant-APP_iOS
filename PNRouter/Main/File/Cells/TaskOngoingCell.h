//
//  TaskOngoingCell.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FileData;
typedef void(^ClickSelectBlcok)(NSArray *values);

NS_ASSUME_NONNULL_BEGIN

static NSString *TaskOngoingCellReuse = @"TaskOngoingCell";
#define TaskOngoingCellHeight 64

@interface TaskOngoingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *fileImgView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblProgess;
@property (weak, nonatomic) IBOutlet UILabel *lblSize;
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UIProgressView *progess;
@property (nonatomic , strong) FileData *fileModel;
@property (weak, nonatomic) IBOutlet UIButton *optionBtn;
@property (nonatomic ,copy) ClickSelectBlcok selectBlock;

- (void) setFileModel:(FileData *) model isSelect:(BOOL) isSelect;
- (void) updateSelectShow:(BOOL) isShow;

@end

NS_ASSUME_NONNULL_END
