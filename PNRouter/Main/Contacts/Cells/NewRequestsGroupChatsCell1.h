//
//  NewRequestsGroupChatsCell1.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/13.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GroupVerifyModel;

static NSString *NewRequestsGroupChatsCell1Reuse = @"NewRequestsGroupChatsCell1";
#define NewRequestsGroupChatsCell1Height 110

typedef void(^GroupChatsRequestAcceptBlock)(NSInteger currentRow);

@interface NewRequestsGroupChatsCell1 : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImgV;
@property (weak, nonatomic) IBOutlet UILabel *toNameLab;
@property (weak, nonatomic) IBOutlet UILabel *fromNameLab;
@property (weak, nonatomic) IBOutlet UILabel *gNameLab;
@property (weak, nonatomic) IBOutlet UIButton *acceptBtn;
@property (weak, nonatomic) IBOutlet UILabel *statusLab;

@property (nonatomic) NSInteger currentRow;
@property (nonatomic, copy) GroupChatsRequestAcceptBlock acceptB;

- (void)configCellWithModel:(GroupVerifyModel *)model;

@end

NS_ASSUME_NONNULL_END
