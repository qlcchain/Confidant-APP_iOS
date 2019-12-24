//
//  TaskCompletedCell.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FileData;
@class PNFileModel;

typedef void(^ClickSelectBlcok)(NSArray *values);

NS_ASSUME_NONNULL_BEGIN

static NSString *TaskCompletedCellReuse = @"TaskCompletedCell";
#define TaskCompletedCellHeight 64

@interface TaskCompletedCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblDesc;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UIImageView *fileImgView;
@property (weak, nonatomic) IBOutlet UIImageView *selectImgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftContraintW;
@property (nonatomic ,copy) ClickSelectBlcok selectBlock;
@property (nonatomic ,copy) NSString *srcKey;
@property (nonatomic ,assign) NSInteger fileId;

- (void) setFileModel:(FileData *) model isSelect:(BOOL) isSelect;
- (void) setPhotoFileModel:(PNFileModel *) model isSelect:(BOOL) isSelect;
- (void) updateSelectShow:(BOOL) isShow;
@end

NS_ASSUME_NONNULL_END
