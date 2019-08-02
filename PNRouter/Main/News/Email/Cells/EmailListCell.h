//
//  EmailListCell.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/9.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MailCore/MailCore.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *EmailListCellResue = @"EmailListCell";
#define EmailListCellHeight 96


@interface EmailListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *lblTtile;
@property (weak, nonatomic) IBOutlet UILabel *lblSubTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UIImageView *lableImgView;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UIImageView *attachImgView;
@property (weak, nonatomic) IBOutlet UILabel *lblAttCount;
@property (weak, nonatomic) IBOutlet UIView *readView;

@property (nonatomic, strong) MCOIMAPMessageRenderingOperation *messageRenderingOperation;

@end

NS_ASSUME_NONNULL_END
