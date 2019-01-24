//
//  UploadAlertView.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/21.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^UploadPhotoBlock)(void);
typedef void(^UploadVideoBlock)(void);
typedef void(^UploadDocumentBlock)(void);
typedef void(^UploadOtherBlock)(void);

@interface UploadAlertView : UIView

@property (nonatomic, copy) UploadPhotoBlock photoB;
@property (nonatomic, copy) UploadVideoBlock videoB;
@property (nonatomic, copy) UploadDocumentBlock documentB;
@property (nonatomic, copy) UploadOtherBlock otherB;

+ (instancetype)getInstance;
- (void)show;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
