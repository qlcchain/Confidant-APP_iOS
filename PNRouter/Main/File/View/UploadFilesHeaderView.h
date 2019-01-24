//
//  UploadFilesHeaderView.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class UploadFilesShowModel;

static NSString *UploadFilesHeaderViewReuse = @"UploadFilesHeaderView";
#define UploadFilesHeaderViewHeight 56

typedef void(^UploadFilesSelectBlock)(void);
typedef void(^UploadFilesShowCellBlock)(void);

@interface UploadFilesHeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UIButton *showCellBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *detailLab;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImg;
@property (nonatomic, copy) UploadFilesSelectBlock selectB;
@property (nonatomic, copy) UploadFilesShowCellBlock showCellB;

- (void)configHeaderWithModel:(UploadFilesShowModel *)model;

@end

NS_ASSUME_NONNULL_END
