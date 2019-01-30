//
//  UploadFileHelper.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/30.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UploadFileHelper : NSObject

+ (instancetype)shareObject;
- (void)showUploadAlertView:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
