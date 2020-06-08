//
//  PNFeedbackListCell.m
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/20.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "PNFeedbackListCell.h"
#import "PNFeedbackMoel.h"
#import "NSDate+Category.h"

@implementation PNFeedbackListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _backV.layer.cornerRadius = 8.0;
}

- (void) setFeedbackModel:(PNFeedbackMoel *) model
{
    _lblNo.text = model.number;
    _lblType.text = model.type;
    _lblTime.text = @"";
    _lblStatus.text = model.status;
    _lblSuject.text = model.scenario;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    if (model.createDate.length > 0) {
        NSDate *startDate = [dateFormatter dateFromString:model.createDate?:@""];
        _lblTime.text = [startDate minuteDescription];
    }
    
}

@end
