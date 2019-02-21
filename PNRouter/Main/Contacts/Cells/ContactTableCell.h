//
//  ContactTableCell.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/2/21.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ContactRouterModel;

static NSString *ContactTableCellResue = @"ContactTableCell";
#define ContactTableCellHeight 48

typedef void(^ContactChatBlock)(ContactRouterModel *crModel);

@interface ContactTableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UIButton *chatBtn;
@property (nonatomic, copy) ContactChatBlock contactChatB;

- (void)configCellWithModel:(ContactRouterModel *)model;

@end

NS_ASSUME_NONNULL_END
