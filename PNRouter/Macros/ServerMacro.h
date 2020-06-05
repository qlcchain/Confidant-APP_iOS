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


#if DEBUG
static NSString *PUSH_URL = @"https://pprouter.online:9001/v1/pareg/appPushInfoReg/";
#else
static NSString *PUSH_URL = @"https://pprouter.online:9001/v1/pareg/appPushInfoReg/";
#endif

static NSString *QLC_TEST_URL = @"http://47.103.54.171:29735";

#if DEBUG
static NSString *LOG_TEST_URL = @"https://47.244.138.61:9001/v1/pprmap/ulogstr";
#else
static NSString *LOG_TEST_URL = @"https://pprouter.online:9001/v1/pprmap/ulogstr";
#endif

// 活动推广
static NSString *Campaign_List_Url = @"http://confidantop.qlink.mobi/capi/msg/list.json";
static NSString *Campaign_Time_Url =  @"http://confidantop.qlink.mobi/capi/sys/dict.json";
// 意见反馈
//static NSString *Feedback_Url = @"http://confidantop.qlink.mobi/capi/feedback/submit.json";
//static NSString *Feedback_Local_Url = @"http://192.168.0.190:8080";
static NSString *Feedback_Url = @"http://confidantop.qlink.mobi/capi/feedback/submit.json";
static NSString *Feedback_Reply_Url = @"http://confidantop.qlink.mobi/capi/feedback/add.json";
static NSString *Feedback_Type_Url = @"http://confidantop.qlink.mobi/capi/sys/dict.json";
static NSString *Feedback_List_Url = @"http://confidantop.qlink.mobi/capi/feedback/list.json";
static NSString *Feedback_Marked_Url = @"http://confidantop.qlink.mobi/capi/feedback/resolved.json";
static NSString *Feedback_Img_BaseUrl = @"http://confidantop.qlink.mobi";

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
