//
//  ChatListModel.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/15.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "BBaseModel.h"

@interface ChatListModel : BBaseModel

@property (nonatomic ,strong) NSString *friendID;
@property (nonatomic ,strong) NSString *myID;
@property (nonatomic ,strong) NSString *publicKey;
@property (nonatomic ,strong) NSString *signPublicKey;
@property (nonatomic ,strong) NSString *friendName;
@property (nonatomic ,strong) NSString *lastMessage;
@property (nonatomic ,strong) NSDate *chatTime;
@property (nonatomic , assign) BOOL isHD;
@property (nonatomic , assign) BOOL isDraft;
@property (nonatomic ,strong) NSString *draftMessage;
@property (nonatomic ,strong) NSString *routerName;

@end
