//
//  PNFeedbackDeatilCell.m
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/26.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "PNFeedbackDeatilCell.h"
#import "NSDate+Category.h"
#import "PNFeedbackMoel.h"
#import "UserModel.h"
#import "PNFeedbackReplayModel.h"

@interface PNFeedbackDeatilCell()

@property (nonatomic, strong) id replyM;

@end

@implementation PNFeedbackDeatilCell
- (IBAction)clickCheckImgAction:(id)sender {
    if (_clickImgBlock) {
        if ([_replyM isKindOfClass:[PNFeedbackMoel class]]) {
            PNFeedbackMoel *model = (PNFeedbackMoel*)_replyM;
            _clickImgBlock(model.imageList);
        } else {
            PNFeedbackReplayModel *model = (PNFeedbackReplayModel*)_replyM;
            _clickImgBlock(model.imageList);
        }
        
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _backV.layer.cornerRadius = 4.0f;
    // Initialization code
}
- (IBAction)clickImgAction:(id)sender {
}

- (void) setFeedReplyModel:(id) model
{
    self.replyM = model;
    if ([model isKindOfClass:[PNFeedbackMoel class]]) {
        PNFeedbackMoel *feedM = (PNFeedbackMoel *)model;
        _lblName.text = [UserModel getUserModel].username;
        _lblContent.text = feedM.question;
        _leftBackV.hidden = YES;
        _backV.backgroundColor = [UIColor whiteColor];
        if (feedM.imageList && feedM.imageList.count > 0) {
            _imgBackView.hidden = NO;
            _imgBtn.hidden = NO;
            _lblImgCount.text = [NSString stringWithFormat:@"%ld",feedM.imageList.count];
            
        } else {
            _imgBackView.hidden = YES;
            _imgBtn.hidden = YES;
        }
        _lblTime.text = @"";
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        if (feedM.createDate.length > 0) {
            NSDate *startDate = [dateFormatter dateFromString:feedM.createDate?:@""];
            _lblTime.text = [startDate minuteDescription];
        }
        
    } else {
        PNFeedbackReplayModel *replyModel = (PNFeedbackReplayModel *)model;
        _lblName.text = replyModel.userName;
        _lblContent.text = replyModel.content;
        _leftBackV.hidden = NO;
        
        if (replyModel.userId && replyModel.userId.length > 0) {
            _backV.backgroundColor = [UIColor whiteColor];
            _leftBackV.hidden = YES;
        } else {
            _leftBackV.hidden = NO;
            _backV.backgroundColor = RGB(250, 248, 255);
        }
        
        if (replyModel.imageList && replyModel.imageList.count > 0) {
            _imgBackView.hidden = NO;
            _imgBtn.hidden = NO;
            _lblImgCount.text = [NSString stringWithFormat:@"%ld",replyModel.imageList.count];
            
        } else {
            _imgBackView.hidden = YES;
             _imgBtn.hidden = YES;
        }
        _lblTime.text = @"";
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        if (replyModel.createDate.length > 0) {
            NSDate *startDate = [dateFormatter dateFromString:replyModel.createDate?:@""];
            _lblTime.text = [startDate minuteDescription];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
