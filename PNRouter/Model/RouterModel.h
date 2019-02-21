//
//  RouterModel.h
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/11.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "BBaseModel.h"

@interface RouterModel : BBaseModel

@property (nonatomic, copy) NSString *toxid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *userSn;
@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *userPass;
@property (nonatomic, assign) int routerToxNumber;
//@property (nonatomic, copy) NSString *alias;
@property (nonatomic) BOOL isConnected;
+ (BOOL)routerIsExitsWithToxid:(NSString *)toxid;
+ (NSArray *)getLocalRouter;
+ (void)addRouterWithToxid:(NSString *)toxid;
+ (void)addRouterWithToxid:(NSString *)toxid usesn:(NSString *) usesn userid:(NSString *) uesrid;
+ (void)updateRouterName:(NSString *)name usersn:(NSString *)sn;
+ (void)updateRouterConnectStatusWithSn:(NSString *)sn;
+ (void)updateRouterLoginSwitchWithSn:(NSString *)sn isOpen:(BOOL) isOpen;
+ (void)updateRouterPassWithSn:(NSString *)sn pass:(NSString *) pass;
+ (void)updateRouterNumberWithSn:(NSString *)sn toxNumber:(int ) toxNumber;
+ (RouterModel *)getConnectRouter;
+ (RouterModel *)getLoginOpenRouter;
+ (NSArray *)getRouterExceptConnect;
+ (void)deleteRouterWithUsersn:(NSString *)sn;
+ (RouterModel *) checkRoutherWithToxid:(NSString *)toxid;
+ (RouterModel *) checkRoutherWithSn:(NSString *) sn;
+ (BOOL)routerIsExitsWithSn:(NSString *)sn;
+ (NSMutableArray *) checkRoutherArrayWithToxid:(NSString *)toxid;
+ (void) delegateAllRouter;
+ (void) addRouterName:(NSString *) routerName routerid:(NSString *) rid usersn:(NSString *) usersn;
@end
