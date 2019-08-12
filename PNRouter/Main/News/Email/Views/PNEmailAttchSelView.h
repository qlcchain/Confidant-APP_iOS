//
//  PNEmailAttchSelView.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/24.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^ClickEnumBlock)(NSInteger row);

@interface PNEmailAttchSelView : UIView

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backContraintBottom;
@property (weak, nonatomic) IBOutlet UIView *backV;
@property (nonatomic, copy) ClickEnumBlock emumBlock;

+ (instancetype) loadPNEmailAttchSelView;
- (void) showEmailAttchSelView;
@end

NS_ASSUME_NONNULL_END
