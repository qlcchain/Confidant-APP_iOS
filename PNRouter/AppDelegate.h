//
//  AppDelegate.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/4.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTabbarViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
//@property (nonatomic, strong) NSString *curLoginToxid;
//@property (nonatomic, strong) NSString *curLoginUsername;
@property (nonatomic ,assign) int currentRouterNumber;
@property (nonatomic ,strong) id<OCTManager> manager;
@property (nonatomic ,assign) BOOL showHD;
@property (nonatomic ,assign) BOOL isLogOut;
@property (nonatomic ,assign) BOOL isConnect; // 记录当前是不是已连接。如果是就不用再管第二次udp
@property (nonatomic ,assign) BOOL isScaner;
@property (nonatomic ,assign) BOOL isDisConnectLogin;
@property (nonatomic ,copy) NSString *regId;
@property (nonatomic ,assign) BOOL isLoginMac;


/**
 app是否正在进行登录操作
 */
@property (nonatomic ,assign) BOOL inLogin;

- (void)setRootTabbarWithManager:(id<OCTManager>) manager;
- (void) setRootLogin;
@end

