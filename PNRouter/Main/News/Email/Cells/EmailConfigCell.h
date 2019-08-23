//
//  EmailConfigCell.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/8/14.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * _Nullable EmailConfigCellResue = @"EmailConfigCell";
#define EmailConfigCellHeight 94

NS_ASSUME_NONNULL_BEGIN

typedef void(^ClickBackBlock)(NSInteger section);

@interface EmailConfigCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *contentTF;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImgV;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passOpenW;
@property (nonatomic ,assign) BOOL isPassOpen;

@property (nonatomic, copy) ClickBackBlock backBlock;

@end

NS_ASSUME_NONNULL_END
