//
//  FingetprintVerificationUtil.m
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/10.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "FingerprintVerificationUtil.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface FingerprintVerificationUtil ()

@property (nonatomic, strong) LAContext *unlockContext;

@end

@implementation FingerprintVerificationUtil


//+ (void)show {
//    //首先判断版本
//    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0) {
//        DDLogDebug(@"系统版本不支持TouchID");
//        return;
//    }
//
//    LAContext *context = [[LAContext alloc] init];
//    context.localizedFallbackTitle = @"Enter Password";
//    if (@available(iOS 10.0, *)) {
//        //        context.localizedCancelTitle = @"22222";
//    } else {
//        // Fallback on earlier versions
//    }
//    NSError *error = nil;
//    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
//        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"Fingerprint verification" reply:^(BOOL success, NSError * _Nullable error) {
//            if (success) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    DDLogDebug(@"TouchID验证成功");
////                    [AppD.window showHint:@"Authentication is successful"];
//                });
//            } else if(error) {
//                switch (error.code) {
//                    case LAErrorAuthenticationFailed:{
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            DDLogDebug(@"TouchID 验证失败");
//                            [FingetprintVerificationUtil exitAPP];
//                        });
//                        break;
//                    }
//                    case LAErrorUserCancel:{
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            DDLogDebug(@"TouchID 被用户手动取消");
//                            [FingetprintVerificationUtil exitAPP];
//                        });
//                    }
//                        break;
//                    case LAErrorUserFallback:{
//                        DDLogDebug(@"TouchID 用户手动输入密码");
//                        [FingetprintVerificationUtil verificationPassword];
//                    }
//                        break;
//                    case LAErrorSystemCancel:{
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            DDLogDebug(@"TouchID 被系统取消 (如遇到来电,锁屏,按了Home键等)");
//                            [FingetprintVerificationUtil exitAPP];
//                        });
//                    }
//                        break;
//                    case LAErrorPasscodeNotSet:{
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            DDLogDebug(@"TouchID 无法启动,因为用户没有设置密码");
//                            [FingetprintVerificationUtil exitAPP];
//                        });
//                    }
//                        break;
//                    case LAErrorTouchIDNotEnrolled:{
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            DDLogDebug(@"TouchID 无法启动,因为用户没有设置TouchID");
//                            [FingetprintVerificationUtil exitAPP];
//                        });
//                    }
//                        break;
//                    case LAErrorTouchIDNotAvailable:{
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            DDLogDebug(@"TouchID 无效");
//                            [FingetprintVerificationUtil exitAPP];
//                        });
//                    }
//                        break;
//                    case LAErrorTouchIDLockout:{
//
//                        DDLogDebug(@"TouchID 被锁定(连续多次验证TouchID失败,系统需要用户手动输入密码)");
//                        [FingetprintVerificationUtil verificationPassword];
//
//                    }
//                        break;
//                    case LAErrorAppCancel:{
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            DDLogDebug(@"当前软件被挂起并取消了授权 (如App进入了后台等)");
//                            [FingetprintVerificationUtil exitAPP];
//                        });
//                    }
//                        break;
//                    case LAErrorInvalidContext:{
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            DDLogDebug(@"当前软件被挂起并取消了授权 (LAContext对象无效)");
//                            [FingetprintVerificationUtil exitAPP];
//                        });
//                    }
//                        break;
//                    default:
//                        break;
//                }
//            }
//        }];
//    } else {
//        DDLogDebug(@"当前设备不支持TouchID");
//        [FingetprintVerificationUtil showNotSupport];
//    }
//}

- (LAContext *)unlockContext {
    if (!_unlockContext) {
        _unlockContext = [[LAContext alloc] init];
        _unlockContext.localizedFallbackTitle = @"Enter Password";
    }
    
    return _unlockContext;
}

- (void)backShowWithComplete:(void(^_Nullable)(BOOL success, NSError * _Nullable error))complete {
    NSNumber *screenLock = [HWUserdefault getObjectWithKey:Screen_Lock_Local]?:@(NO);
    if ([screenLock boolValue] == NO) {
        return;
    }
    @weakify_self
    dispatch_async(dispatch_get_main_queue(), ^{
        DDLogDebug(@"开始解锁");
        NSError *error = nil;
        if( [weakSelf.unlockContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error]) {
            [weakSelf.unlockContext evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"Use the fingerprint to continue." reply:^(BOOL success, NSError * _Nullable error) {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        DDLogDebug(@"解锁验证失败");
                        [FingerprintVerificationUtil handleError:error isExit:NO];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        DDLogDebug(@"解锁验证成功");
                        
                    });
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (complete) {
                        complete(success, error);
                    }
                });
            }];
        } else {
            [FingerprintVerificationUtil showNotSupport:@"Touch ID and Face ID are not supported on the current device"];
        }
    });
}

- (void)hide {
    if (self.unlockContext) {
        [self.unlockContext invalidate];
        self.unlockContext = nil;
    }
}
/*
+ (void)backShow
{
    NSNumber *screenLock = [HWUserdefault getObjectWithKey:Screen_Lock_Local]?:@(NO);
    if ([screenLock boolValue] == NO) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        DDLogDebug(@"开始解锁");
        LAContext *myContext = [[LAContext alloc] init];
        myContext.localizedFallbackTitle = @"Enter Password";
        NSError *error = nil;
        if( [myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error])
        {
            [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"Use the fingerprint to continue." reply:^(BOOL success, NSError * _Nullable error) {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        DDLogDebug(@"解锁验证失败");
                        [FingerprintVerificationUtil handleError:error isExit:NO];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        DDLogDebug(@"解锁验证成功");
                    });
                }
            }];
        } else {
            [FingerprintVerificationUtil showNotSupport:@"Touch ID and Face ID are not supported on the current device"];
        }
    });
}
*/
+ (void)show {
   
    dispatch_async(dispatch_get_main_queue(), ^{
        DDLogDebug(@"开始解锁");
        LAContext *myContext = [[LAContext alloc] init];
        myContext.localizedFallbackTitle = @"Enter Password";
        NSError *error = nil;
        if([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error])
        {
            [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"Use the fingerprint to continue." reply:^(BOOL success, NSError * _Nullable error) {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        DDLogDebug(@"解锁验证失败");
                        [FingerprintVerificationUtil handleError:error isExit:YES];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        DDLogDebug(@"解锁验证成功");
                        [[NSNotificationCenter defaultCenter] postNotificationName:TOUCH_MODIFY_SUCCESS_NOTI object:nil];
                    });
                }
            }];
        } else {
            [FingerprintVerificationUtil showNotSupport:@"Touch ID and Face ID are not supported on the current device"];
        }
    });
}

+ (void)checkFloderShow {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        DDLogDebug(@"开始解锁");
        LAContext *myContext = [[LAContext alloc] init];
        myContext.localizedFallbackTitle = @"Enter Password";
        NSError *error = nil;
        if([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error])
        {
            [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:@"Use the fingerprint to continue." reply:^(BOOL success, NSError * _Nullable error) {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        DDLogDebug(@"解锁验证失败");
                        [FingerprintVerificationUtil handleError:error isExit:YES];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        DDLogDebug(@"解锁验证成功");
                    });
                }
            }];
        } else {
            [FingerprintVerificationUtil showNotSupport:@"Touch ID and Face ID are not supported on the current device"];
        }
    });
}

+ (void)handleError:(NSError *)error isExit:(BOOL) isExit{
    //失败操作
    LAError errorCode = error.code;
    switch (errorCode) {
        case LAErrorAuthenticationFailed:
        {
            NSLog(@"授权失败"); // -1 连续三次指纹识别错误
            if (isExit) {
                 [FingerprintVerificationUtil exitAPP];
            }
        }
            break;
        case LAErrorUserCancel: // Authentication was canceled by user (e.g. tapped Cancel button)
        {
            NSLog(@"用户取消验证Touch ID"); // -2 在TouchID对话框中点击了取消按钮
            if (isExit) {
                 [FingerprintVerificationUtil exitAPP];
            }
           
        }
            break;
        case LAErrorUserFallback: // Authentication was canceled, because the user tapped the fallback button (Enter Password)
        {
            NSLog(@"用户选择输入密码，切换主线程处理"); // -3 在TouchID对话框中点击了输入密码按钮
//            [FingerprintVerificationUtil exitAPP];
        }
            break;
        case LAErrorSystemCancel: // Authentication was canceled by system (e.g. another application went to foreground)
        {
            NSLog(@"取消授权，如其他应用切入"); // -4 TouchID对话框被系统取消，例如按下Home或者电源键
           if (isExit) {
                 [FingerprintVerificationUtil exitAPP];
            }
        }
            break;
        case LAErrorPasscodeNotSet: // Authentication could not start, because passcode is not set on the device.
        {
            NSLog(@"设备系统未设置密码"); // -5
            [FingerprintVerificationUtil showNotSupport:@"The device doesn't have a password"];
        }
            break;
        case LAErrorTouchIDNotAvailable: // Authentication could not start, because Touch ID is not available on the device
        {
            NSLog(@"设备未设置Touch ID"); // -6
            [FingerprintVerificationUtil showNotSupport:@"Touch ID is not set on the device"];
        }
            break;
        case LAErrorTouchIDNotEnrolled: // Authentication could not start, because Touch ID has no enrolled fingers
        {
            NSLog(@"用户未录入指纹"); // -7
            [FingerprintVerificationUtil showNotSupport:@"No fingerprint was recorded on the device"];
        }
            break;
        case LAErrorTouchIDLockout: //Authentication was not successful, because there were too many failed Touch ID attempts and Touch ID is now locked. Passcode is required to unlock Touch ID, e.g. evaluating LAPolicyDeviceOwnerAuthenticationWithBiometrics will ask for passcode as a prerequisite 用户连续多次进行Touch ID验证失败，Touch ID被锁，需要用户输入密码解锁，先Touch ID验证密码
        {
            NSLog(@"Touch ID被锁，需要用户输入密码解锁"); // -8 连续五次指纹识别错误，TouchID功能被锁定，下一次需要输入系统密码
//            [FingerprintVerificationUtil exitAPP];
        }
            break;
        case LAErrorAppCancel: // Authentication was canceled by application (e.g. invalidate was called while authentication was in progress) 如突然来了电话，电话应用进入前台，APP被挂起啦");
        {
            NSLog(@"用户不能控制情况下APP被挂起"); // -9
            if (isExit) {
                 [FingerprintVerificationUtil exitAPP];
            }
        }
            break;
        case LAErrorInvalidContext: // LAContext passed to this call has been previously invalidated.
        {
            NSLog(@"LAContext传递给这个调用之前已经失效"); // -10
            if (isExit) {
                 [FingerprintVerificationUtil exitAPP];
            }
        }
            break;
        case LAErrorNotInteractive: {
            NSLog(@"///////////");
            if (isExit) {
                 [FingerprintVerificationUtil exitAPP];
            }
            break;
        }
    }
}

+ (void)showNotSupport:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *alertConfirm = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [FingerprintVerificationUtil exitAPP];
        }];
        [alertC addAction:alertConfirm];
        [AppD.window.rootViewController presentViewController:alertC animated:YES completion:nil];
    });
}

+ (void)exitAPP {
    [AppD.window showHint:@"Failed to verify"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         exit(0);
    });
}

@end
