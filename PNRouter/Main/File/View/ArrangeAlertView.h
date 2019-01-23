//
//  UploadAlertView.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/21.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    ArrangeTypeByName,
    ArrangeTypeByTime,
    ArrangeTypeBySize,
} ArrangeType;

typedef void(^ArrangeClickBlock)(ArrangeType type);

@interface ArrangeAlertView : UIView

@property (nonatomic, copy) ArrangeClickBlock clickB;

+ (instancetype)getInstance;
- (void)showWithArrange:(ArrangeType)type;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
