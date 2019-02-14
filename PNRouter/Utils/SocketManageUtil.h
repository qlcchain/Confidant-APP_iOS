//
//  SocketManageUtil.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/29.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocketManageUtil : NSObject
+ (instancetype) getShareObject;
@property (nonatomic ,strong) NSMutableArray *socketArray;

- (void) clearDisConnectSocket;
- (void) clearAllConnectSocket;
@end
