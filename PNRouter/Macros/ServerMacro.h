//
//  ServerMacro.h
//  Qlink
//
//  Created by Jelly Foo on 2018/3/26.
//  Copyright © 2018年 pan. All rights reserved.
//

#ifndef ServerMacro_h
#define ServerMacro_h

//#define ServerDomain_Test @"http://192.168.1.111"
//#define ServerDomain_Test @"http://47.90.50.172"
//#define ServerDomain_Product @"http://dapp-t.qlink.mobi"

// google api
#define Google_Get_Message_List @"https://www.googleapis.com/gmail/v1/users/%@/messages"

#define PUSH_DEBUG_URL @"http://47.96.76.184:9000/v1/pareg/"
#define PUSH_ONLINE_URL @"https://pprouter.online:9001/v1/pareg/"


#define APIVERSION @"6"
//#define APIVERSION2 @"2"
//#define APIVERSION3 @"3"
//#define APIVERSION4 @"4"
//#define APIVERSION5 @"5"
//#define APIVERSION6 @"6"
#define SOCKET_USETDATAVERSION @"1"

#define Server_Data @"data"
#define Server_Msg @"msg"
#define Server_Code @"code"
#define Server_Code_Success 0

// 是否打印jsonstr
#define K_Print_JsonStr @(YES)

#endif /* ServerMacro_h */
