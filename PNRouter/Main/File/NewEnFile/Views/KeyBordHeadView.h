//
//  KeyBordHeadView.h
//  MyConfidant
//
//  Created by 旷自辉 on 2019/11/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KeyBordHeadView : UIView
@property (weak, nonatomic) IBOutlet UITextField *floderTF;
@property (weak, nonatomic) IBOutlet UIView *tfbackView;

+ (instancetype) getKeyBordHeadView;

@end

NS_ASSUME_NONNULL_END
