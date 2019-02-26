//
//  PNUnlockView.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/2/26.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^UnlockOKBlock)(void);

@interface PNUnlockView : UIView

+ (instancetype)getInstance;
- (void)showWithUnlockOK:(UnlockOKBlock)block;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
