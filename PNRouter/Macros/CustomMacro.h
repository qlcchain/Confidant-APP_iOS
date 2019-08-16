//
//  CustomMacro.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/10.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#ifndef CustomMacro_h
#define CustomMacro_h
// 是否要清人除数据
#define CLEAR_DATA  @"CLEAR_DATA"
#define Connect_Cricle @"Connect the Circle"
#define Switch_Cricle @"Switch the Circle"
#define Switch_Cricle_Failed @"Failed to Switch"
// 数据库表名
#define FRIEND_REQUEST_TABNAME  @"friend_requet_tableName"
// 文件记录表
#define FILE_STATUS_TABNAME     @"file_status_tableName"
#define FRIEND_LIST_TABNAME  @"friend_list_tableName"
// 好友聊天记录表
#define FRIEND_CHAT_TABNAME  @"FRIEND_CHAT_TABNAME"

// 消息缓存表
#define CHAT_CACHE_TABNAME  @"CHAT_CACHE_TABNAME"
// 群组标识
#define GROUP_IDF 6
#define OperationRecord_Table @"OperationRecord_Table"
#define UserHeader_Table @"UserHeader_Table"
// 群组请求通知表
#define Group_New_Requests_TABNAME  @"Group_New_Requests_TABNAME"

// email 最近联系人
#define EMAIL_CONTACT_TABNAME  @"EMAIL_CONTACT_TABNAME"
// email 星标邮件
#define EMAIL_STAR_TABNAME  @"EMAIL_STAR_TABNAME"


// 请求超时时间
#define REQEUST_TIME  20
#define REQEUST_TIME_60  60
#define RADIUS 3.0f
#define BACK_TIME @"BACK_TIME"
#define Bugly_AppID @"d22a5845f9"

#define MAIN_GRAY_COLOR RGB(245, 245, 245)
#define MAIN_ZS_COLOR RGB(102, 70, 247)
#define MAIN_PURPLE_COLOR RGB(44, 44, 44)
#define MAIN_WHITE_COLOR UIColorFromRGB(0xffffff)
#define SHADOW_COLOR UIColorFromRGB(0x333333)
#define TABBAR_RED_COLOR UIColorFromRGB(0xF74C31)

#define TABBARTEXT_SELECT_COLOR UIColorFromRGB(0x2c2c2c)
#define TABBARTEXT_DEFAULT_COLOR UIColorFromRGB(0xb3b3b3)

#define ROUTER_ARR @"router_arrys" // 本地储存的路由器
#define USER_LOCAL @"user_local" // 本地储存的用户信息
#define VERSION_KEY @"version_key" // 存储当前版本
#define TOX_ID_KEY @"tox_id_key" // 存储当前版本
#define AES_KEY  @"welcometoqlc0101" // routesn
#define ROUTER_IP_KEY @"slph$%*&^@-78231"
#define LOGIN_KEY @"login_keys"
#define TOX_DATA_PASS @"123456"
#define FILE_NONCE @"OmcKJrqehqQwNvdHkRBddXYyAvbGW2A1"
#define File_Download_GroupId @"File_Download_GroupId" // 文件下载groupid
#define File_Download_Task_List @"File_Download_Task_List" // 文件下载目录

#pragma mark - socket Action

#pragma mark - socket connect status
static NSInteger socketConnectStatusNone = 0;
static NSInteger socketConnectStatusConnecting = 1;
static NSInteger socketConnectStatusConnected = 2;
static NSInteger socketConnectStatusDisconnecting = 3;
static NSInteger socketConnectStatusDisconnected = 4;

#pragma mark----email floder name
static NSString *Inbox = @"Inbox";
static NSString *Node_backed_up = @"Node backed up";
static NSString *Starred = @"Starred";
static NSString *Drafts = @"Drafts";
static NSString *Sent = @"Sent";
static NSString *Spam = @"Spam";
static NSString *Trash = @"Trash";

#pragma mark - HUD Text
#define Loading_Str @"Loding..."
#define Uploading_Str @"Uploading..."
#define Switching_Str @"Switching..."
#define Deleting_Str @"Deleting..."
#define Updateing_Str @"Updateing..."

#define User_Header_Size 500*1024      // 500KB
#define Screen_Lock_Local @"Screen_Lock_Local"



static NSString * mainJavascript = @"\
var imageElements = function() {\
var imageNodes = document.getElementsByTagName('img');\
return [].slice.call(imageNodes);\
};\
\
var findCIDImageURL = function() {\
var images = imageElements();\
\
var imgLinks = [];\
for (var i = 0; i < images.length; i++) {\
var url = images[i].getAttribute('src');\
if (url.indexOf('cid:') == 0 || url.indexOf('x-mailcore-image:') == 0)\
imgLinks.push(url);\
}\
return JSON.stringify(imgLinks);\
};\
\
var replaceImageSrc = function(info) {\
var images = imageElements();\
\
for (var i = 0; i < images.length; i++) {\
var url = images[i].getAttribute('src');\
if (url.indexOf(info.URLKey) == 0) {\
images[i].setAttribute('src', info.LocalPathKey);\
break;\
}\
}\
};\
";

static NSString * mainStyle = @"\
body {\
font-family: Helvetica;\
font-size: 16px;\
word-wrap: break-word;\
-webkit-text-size-adjust:none;\
-webkit-nbsp-mode: space;\
}\
\
pre {\
white-space: pre-wrap;\
}\
";

static NSString *confidantEmialStr = @" This is an encrypted email, use MyConfidant to decrypt this email.";
static NSString *confidantEmialText = @"This is an encrypted email, use MyConfidant to decrypt this email.";

static NSString *confidantHtmlStr = @"<div myconfidantbegin=''><br />\
<br />\
<br />\
<span>This is an encrypted email, use MyConfidant to decrypt this email.</span></div>";

static NSString *htmlHead = @"<div style=\"padding-bottom: 20px;\"></div><div><html xmlns=\"http://www.w3.org/1999/xhtml\">\
<head>\
<title></title>\
</head>";

#endif /* CustomMacro_h */
