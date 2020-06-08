//
//  PNRecevieQLCAddressView.h
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/18.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ClickEditBlock)(NSInteger tag);
typedef void(^ClickCloseBlock)(void);

@interface PNRecevieQLCAddressView : UIView
@property (weak, nonatomic) IBOutlet UILabel *lblneoAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblqlcAddress;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backV;
@property (copy, nonatomic) ClickEditBlock editBlock;
@property (copy, nonatomic) ClickCloseBlock closeBlock;

+ (instancetype) loadPNRecevieQLCAddressView;
- (void) showPNRecevieQLCAddressView;
- (void) hidePNRecevieQLCAddressView;
@end

NS_ASSUME_NONNULL_END
