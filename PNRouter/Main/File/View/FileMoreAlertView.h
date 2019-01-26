//
//  UploadAlertView.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/21.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^FileMoreClickBlock)(void);

@interface FileMoreAlertView : UIView

@property (nonatomic) FileMoreClickBlock sendB;
@property (nonatomic) FileMoreClickBlock downloadB;
@property (nonatomic) FileMoreClickBlock otherApplicationOpenB;
@property (nonatomic) FileMoreClickBlock detailInformationB;
@property (nonatomic) FileMoreClickBlock renameB;
@property (nonatomic) FileMoreClickBlock deleteB;

+ (instancetype)getInstance;
- (void)showWithFileName:(NSString *)fileName;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
