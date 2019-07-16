//
//  PNEmailOptionEnumView.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/16.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SkyRadiusView.h"

typedef void(^ClickEnumBlock)(NSInteger row);

NS_ASSUME_NONNULL_BEGIN

@interface PNEmailOptionEnumView : UIView
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UITableView *mainTabView;
@property (weak, nonatomic) IBOutlet SkyRadiusView *backView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backContraintBottom;
@property (nonatomic, copy) ClickEnumBlock emumBlock;
+ (instancetype) loadPNEmailOptionEnumView;
- (void) showEmailOptionEnumView;

@end

NS_ASSUME_NONNULL_END
