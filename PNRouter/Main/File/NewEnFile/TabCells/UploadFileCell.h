//
//  UploadFileCell.h
//  MyConfidant
//
//  Created by 旷自辉 on 2019/11/21.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *UploadFileCellResue = @"UploadFileCell";
#define UploadFileCellHeight 76.0f

@interface UploadFileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *typeImgView;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblDesc;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UIButton *optionBtn;

@end

NS_ASSUME_NONNULL_END
