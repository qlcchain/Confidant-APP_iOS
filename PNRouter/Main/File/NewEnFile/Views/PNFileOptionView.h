//
//  PNFileOptionView.h
//  MyConfidant
//
//  Created by 旷自辉 on 2019/11/26.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ClickOptionMenuBlock)(NSInteger tag);

@interface PNFileOptionView : UIView

@property (weak, nonatomic) IBOutlet UIView *backV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backContraintV;
@property (nonatomic, copy) ClickOptionMenuBlock clickMenuBlock;

+ (instancetype) loadPNFileOptionView;
- (void) showOptionEnumView;
@end

NS_ASSUME_NONNULL_END
