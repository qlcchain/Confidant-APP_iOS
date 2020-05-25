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

// 加密文件夹表
#define EN_FLODER_TABNAME @"EN_FLODER_TABNAME"
// 加密文件表
#define EN_FILE_TABNAME @"EN_FILE_TABNAME"


// 埋点事件名
#define FIR_ADD_NEW_CHAT @"main_Add_newchat"
#define FIR_ADD_NEW_EMAIL @"main_Add_email"
#define FIR_ADD_CONTACTS @"main_Add_addcontacts"
#define FIR_ADD_INVITE_FRIENDS @"main_Add_invite_friends"
#define FIR_ADD_MEMBERS @"main_Add_members"
#define FIR_IMPORT_ACCOUNT @"import_account"
#define FIR_LOGIN  @"start_login"
#define FIR_REGISTER @"start_register"
#define FIR_EMAIL_CONFIG @"start_email_config"
#define FIR_EMAIL_SEND   @"start_emailSend"
#define FIR_CHAT_SEND_TEXT    @"start_chat_send_text"
#define FIR_CHAT_DEL  @"start_chat_delete"
#define FIR_CHAT_SEND_FILE    @"start_chat_sendFile"
#define FIR_CHAT_ADD_FRIEND   @"start_chat_AddFriend"
#define FIR_CHAT_ADD_GROUP   @"start_chat_AddGroup"
#define FIR_CHAT_SEND_GROUP_TEXT    @"start_chat_SendGroupText"
#define FIR_CHAT_SEND_GROUP_FILE    @"start_chat_SendGroupFile"
#define FIR_FLODER_CREATE    @"start_floderCreate"
#define FIR_FLODER_UPLOAD_FILE    @"start_floderUploadFile"
#define FIR_CONTACTS_SYNC    @"start_contactsSync"
#define FIR_CONTACTS_RECOVER    @"start_contactsRecover"
#define FIR_CONTACT_DEL  @"start_contactDelete"
// 推广活动埋点
#define FIR_ADD_WALLET_ADDRESS  @"add_wallet_address"
#define FIR_CHECK_CAMPAIGN  @"check_campaign"


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

#define libkey @"libkey"
#define ROUTER_ARR @"router_arrys" // 本地储存的路由器
#define USER_LOCAL @"user_local" // 本地储存的用户信息
#define VERSION_KEY @"version_key" // 存储当前版本
#define TOX_ID_KEY @"tox_id_key" // 存储当前版本
#define AES_KEY  @"welcometoqlc0101" // routesn
#define ROUTER_IP_KEY @"slph$%*&^@-78231"
#define LOGIN_KEY @"login_keys"
#define TOX_DATA_PASS @"123456"
#define FILE_NONCE @"OmcKJrqehqQwNvdHkRBddXYyAvbGW2A1"
#define EN_NONCE @"QUFBQUFBQUFBQUFBQUFBQUFBQUFBQUFB"
#define File_Download_GroupId @"File_Download_GroupId" // 文件下载groupid
#define File_Download_Task_List @"File_Download_Task_List" // 文件下载目录
#define Login_Statu_Key @"Login_Statu_Key"
#define Campaing_ids_key @"Campaing_ids_key" // 活动消息key

#pragma mark -日志打点 Action
static int LOGIN = 0x01;
static int ADDFRIENDREQ  = 3;
static int ADDFRIENDDEAL = 5;
static int DELFRIENDCMD  = 7;
static int SENDMSG = 9;
static int PULLMSG = 18;
static int PULLFRIEND = 19;
static int REGISTER = 27;
static int GROUPLISTPULL = 56;
static int GROUPUSERPULL = 57;
static int GROUPMSGPULL = 58;
static int GROUPSENDMSG = 59;


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
#define Loading_Str @"Loading..."
#define Uploading_Str @"Uploading..."
#define Switching_Str @"Switching..."
#define Deleting_Str @"Deleting..."
#define Updateing_Str @"Updateing..."

#define Update_Success_Str @"Modified successfully!"
#define Save_Success_Str @"Saved successfully!"
#define Delete_Success_Str @"Delete successfully!"
#define Send_Success_Str @"Saved successfully!"
#define Recover_Success @"Backed up successfully!"

#define Registered_Failed @"Failed to registered"
#define Update_Failed @"Failed to modify"
#define Configured_Failed @"Failed to Configured"
#define Connect_Failed @"Failed to connect"
#define Delete_Failed  @"Failed to delete"
#define Create_Failed @"Failed to create"
#define Send_Faield @"Failed to send"
#define Failed @"Failed"
#define Decrypt_Failed @"Failed to decrypt"

#define Device_No @"The device is not supported."
#define Scan_Failed @"Failed to scan"

#define User_Header_Size 500*1024      // 500KB
#define Screen_Lock_Local @"Screen_Lock_Local"


static NSString *encoderShowContent = @"<div id='box'>\
<style type='text/css'>\
* {\
padding: 0;\
border: 0;\
outline: 0;\
margin: 0;\
}\
a {\
    text-decoration: none;\
    background-color: transparent\
}\
a:hover,\
a:active {\
    outline-width: 0;\
    text-decoration: none\
}\
#box {\
width: 100vw;\
box-sizing: border-box;\
}\
#box section {\
padding: 16px;\
}\
#box header .Star {\
float: right;\
}\
.userHead {\
display: flex;\
width: 100%;\
    box-sizing: border-box;\
    border-bottom: 1px solid #e6e6e6;\
}\
.userHeadA {\
width: 44px;\
height: 44px;\
padding: 18px 0;\
}\
.userHeadB {\
width: 240px;\
height: 44px;\
padding: 18px 0;\
outline: 0px solid #ccc;\
}\
.userHeadC {\
flex: 1;\
    text-align: right;\
height: 44px;\
padding: 18px 0;\
outline: 0px solid #ccc;\
}\
.userHeadAimg {\
width: 44px;\
height: 44px;\
    border-radius: 22px;\
}\
.userHeadBdate {\
color: #ccc;\
    margin-left: 8px;\
}\
.rowDiv {\
padding: 20px 0;\
    text-align: center;\
    border-bottom: 1px solid #e6e6e6;\
}\
button {\
background: rgba(102, 70, 247, 1);\
    border-radius: 7px;\
color: #fff;\
}\
.rowDiv3Btn {\
padding: 12px 34px;\
background: rgba(102, 70, 247, 1);\
    border-radius: 7px;\
color: #fff;\
}\
.rowDiv h3 {\
    font-size: 18px;\
    line-height: 18px;\
}\
.h3logo {\
position: relative;\
top: 5px;\
width: 24px;\
margin-right: 5px;\
}\
#box p {\
line-height: 20px;\
font-size: 12px;\
}\
#box h3 {\
line-height: 40px;\
}\
.qrcodeDIV2 {\
width:50%;\
float:left;\
outline:1px solid red;\
}\
.jusCenter {\
display: flex;\
justify-content: center;\
align-items: center;\
}\
</style>\
<section>\
<div class='rowDiv'>\
<h3><img class='h3logo' src='https://confidant.oss-cn-hongkong.aliyuncs.com/images/confidant_logo_n.png'>Encrypted Email</h3>\
<p>Encrypted email client and beyond - your comprehensive privacy&nbsp;protection tool</p>\
</div>\
<div class='rowDiv' style='border: 0;'>\
<p style='font-size: 14px;'>You just received a secure message from</p>\
<h3 style='color:#6646F7'>xxx</h3>\
<p style='font-size: 14px;'>I’m using Confidant to send and receive secure emails. Download and install Confidant to decrypt and read the email content via the link below.</p>\
</div>\
<div class='rowDiv jusCenter' style='text-align: center;padding: 0;'>\
<div style='padding:15px;'>\
<a href='https://apps.apple.com/us/app/my-confidant/id1456735273?l=zh&ls=1'><img width='140' src='https://confidant.oss-cn-hongkong.aliyuncs.com/images/apps_tore.png'></a>\
</div>\
<div style='padding:15px;'>\
<a href='https://play.google.com/store/apps/details?id=com.stratagile.pnrouter'><img width='140' src='https://confidant.oss-cn-hongkong.aliyuncs.com/images/google_play.png'></a>\
</div>\
</div>\
</section>\
</div>";
///< myconfidantbegin=''><br /><br /><br /><span>&nbsp;&nbsp;Sent from MyConfidant, the app for encrypted email.</span></div>";

// 非加密邮件客户端显示
static NSString *noEncoderShowContent = @"<div id='box'>\
<style type='text/css'>\
* {\
padding: 0;\
border: 0;\
outline: 0;\
margin: 0;\
}\
a {\
    text-decoration: none;\
    background-color: transparent\
}\
a:hover,\
a:active {\
    outline-width: 0;\
    text-decoration: none\
}\
#box {\
width: 100vw;\
box-sizing: border-box;\
}\
#box section {\
padding: 16px;\
}\
#box header .Star {\
float: right;\
}\
.userHead {\
display: flex;\
width: 100%;\
    box-sizing: border-box;\
    border-bottom: 1px solid #e6e6e6;\
}\
.userHeadA {\
width: 44px;\
height: 44px;\
padding: 18px 0;\
}\
.userHeadB {\
width: 240px;\
height: 44px;\
padding: 18px 0;\
outline: 0px solid #ccc;\
}\
.userHeadC {\
flex: 1;\
    text-align: right;\
height: 44px;\
padding: 18px 0;\
outline: 0px solid #ccc;\
}\
.userHeadAimg {\
width: 44px;\
height: 44px;\
    border-radius: 22px;\
}\
.userHeadBdate {\
color: #ccc;\
    margin-left: 8px;\
}\
.rowDiv {\
padding: 20px 0;\
    text-align: center;\
    border-bottom: 1px solid #e6e6e6;\
}\
button {\
background: rgba(102, 70, 247, 1);\
    border-radius: 7px;\
color: #fff;\
}\
.rowDiv3Btn {\
padding: 12px 34px;\
background: rgba(102, 70, 247, 1);\
    border-radius: 7px;\
color: #fff;\
}\
.rowDiv h3 {\
    font-size: 18px;\
    line-height: 18px;\
}\
.h3logo {\
position: relative;\
top: 5px;\
width: 24px;\
margin-right: 5px;\
}\
#box p {\
line-height: 20px;\
font-size: 12px;\
}\
#box h3 {\
line-height: 40px;\
}\
.qrcodeDIV2 {\
width:50%;\
float:left;\
outline:1px solid red;\
}\
.jusCenter {\
display: flex;\
justify-content: center;\
align-items: center;\
}\
</style>\
<section>\
<div class='rowDiv'>\
<h3><img class='h3logo' src='https://confidant.oss-cn-hongkong.aliyuncs.com/images/confidant_logo_n.png'>Encrypted Email</h3>\
<p>Encrypted email client and beyond - your comprehensive privacy&nbsp;protection tool</p>\
</div>\
<div class='rowDiv' style='border: 0;'>\
<p style='font-size: 14px;'>You just received a secure message from</p>\
<h3 style='color:#6646F7'>xxx</h3>\
<p style='font-size: 14px;'>I’m using Confidant to send and receive secure emails. Download and install Confidant to decrypt and read the email content via the link below.</p>\
</div>\
<div class='rowDiv jusCenter' style='text-align: center;padding: 0;'>\
<div style='padding:15px;'>\
<a href='https://apps.apple.com/us/app/my-confidant/id1456735273?l=zh&ls=1'><img width='140' src='https://confidant.oss-cn-hongkong.aliyuncs.com/images/apps_tore.png'></a>\
</div>\
<div style='padding:15px;'>\
<a href='https://play.google.com/store/apps/details?id=com.stratagile.pnrouter'><img width='140' src='https://confidant.oss-cn-hongkong.aliyuncs.com/images/google_play.png'></a>\
</div>\
</div>\
</section>\
</div>";

// 好友邀请模板
static NSString *friendMBHtml = @"<div id='box'>\
<style type='text/css'>\
* {\
padding: 0;\
border: 0;\
outline: 0;\
margin: 0;\
}\
a {\
text-decoration: none;\
background-color: transparent\
}\
a:hover,\
a:active {\
outline-width: 0;\
text-decoration: none\
}\
#box{\
margin: 0 auto;\
box-sizing: border-box;\
max-width: 720px;\
}\
#box section {\
padding: 16px;\
}\
#box header .Star {\
float: right;\
}\
.userHead {\
display: flex;\
width: 100%;\
box-sizing: border-box;\
border-bottom: 1px solid #e6e6e6;\
}\
.userHeadA {\
width: 44px;\
height: 44px;\
padding: 16px 0;\
}\
.userHeadB {\
width: 240px;\
height: 44px;\
padding: 16px 0;\
outline: 0px solid #ccc;\
}\
.userHeadC {\
flex: 1;\
text-align: right;\
height: 44px;\
padding: 18px 0;\
outline: 0px solid #ccc;\
}\
.userHeadAimg {\
width: 44px;\
height: 44px;\
border-radius: 22px;\
}\
.userHeadBdate {\
color: #ccc;\
margin-left: 8px;\
}\
.rowDiv {\
padding: 20px 0;\
}\
button {\
background: rgba(102, 70, 247, 1);\
border-radius: 7px;\
color: #fff;\
}\
.rowDiv3Btn {\
padding: 12px 34px;\
background: rgba(102, 70, 247, 1);\
border-radius: 7px;\
color: #fff;\
}\
.rowDiv h3 {\
font-size: 16px;\
line-height: 16px;\
}\
#box p {\
line-height: 20px;\
font-size: 12px;\
}\
#box h3 {\
line-height: 40px;\
}\
.qrcodeDIV {\
width: 120px;\
margin: 0 30px;\
}\
.qrcodeDIV img {\
width: 120px;\
}\
.btn {\
width: 120px;\
height: 22px;\
display: block;\
}\
.btn img {\
width: 100%;\
height: 100%;\
}\
.h3logo {\
position: relative;\
top: 5px;\
width: 24px;\
margin-right: 5px;\
}\
.includePng {\
float: right;\
width: 110px;\
position: relative;\
top: -24px;\
}\
.rowDivBtn {\
display: flex;\
width: 100%;\
justify-content: space-between;\
}\
.rowDivBtn div {\
width: 158px;\
height: 42px;\
margin:5px;\
}\
.rowDivBtn .rowDivBtnAddlong {\
width: 179px;\
}\
.rowDivBtn img {\
width: 100%;\
}\
.jusCenter {\
display: flex;\
justify-content: center;\
align-items: center;\
}\
.rowDivFooter {\
background: #292B33;\
color: #fff;\
text-align: center;\
}\
#box .rowDivFooter p {\
line-height: 30px;\
}\
.rowDivFooter i {\
outline: 0px solid red;\
font-style: normal;\
overflow: hidden;\
height: 9px;\
width: 15px;\
display: inline-block;\
line-height: 15px;\
position: relative;\
top: -6px;\
color: #6646F7;\
}\
.rowDivFooter i:last-child {\
top: 0px;\
height: 7px;\
line-height: 0px;\
top: 2px;\
}\
.rowDivSave {\
text-align: center;\
border-bottom: 1px solid #E6E6E6;\
padding: 0 0 30px 0;\
}\
@media only screen and (min-width: 992px) {\
#box{\
width:706px;\
}\
}\
@media only screen and (min-width: 1200px) {\
#box{\
width:680px;\
background: white;\
}\
}\
</style>\
<section>\
<div class='rowDiv'>\
<h3>Dear,<br/> Greetings from xxx!</h3>\
<p>This invitation was sent to you from your friend using Confidant, which is the platform for secure\
&nbsp;encrypted Email and message communication. </p>\
<p>You are invited to join him/her to stay in touch in a private and secure manner.</p>\
<br/>\
<p style='font-size: 14px;'>To instantly access Confidant full services</p>\
</div>\
<div class='rowDiv' style='padding: 5px 0;'>\
<p style='color: #757380;'>1. Download the app via </p>\
</div>\
<div class='rowDiv jusCenter' style='text-align: center;padding: 0'>\
<div class='qrcodeDIV'>\
<img src='https://confidant.oss-cn-hongkong.aliyuncs.com/images/confidant_app_qr.png'>\
<a href='https://apps.apple.com/us/app/my-confidant/id1456735273?l=zh&ls=1'><img src='https://confidant.oss-cn-hongkong.aliyuncs.com/images/confidant_ios.png'></a>\
</div>\
<div class='qrcodeDIV'>\
<img src='https://confidant.oss-cn-hongkong.aliyuncs.com/images/confidant_google_qr.png'>\
<a href='https://play.google.com/store/apps/details?id=com.stratagile.pnrouter'><img src='https://confidant.oss-cn-hongkong.aliyuncs.com/images/confidant_google.png'></a>\
</div>\
</div>\
<div class='rowDiv'><p style='color: #757380;border-bottom: 1px solid #e6e6e6;padding: 10px 0px 30px 0px;'>2.Scan your friend's QR code in the attachment to start chatting</p></div>\
<div class='rowDiv'>\
<p style='color: #757380;'>Once done, we highly encourage you to send back a thank you message to your friend.</p>\
<p style='color: #757380;'>Stay safe and secured!</p>\
</div>\
<div class='rowDiv'>\
<img style='width: 100%;' src='https://confidant.oss-cn-hongkong.aliyuncs.com/images/tie_se.png' />\
</div>\
<div class='rowDiv'>\
<img style='width: 100%;' src='https://confidant.oss-cn-hongkong.aliyuncs.com/images/logo_we.png' />\
</div>\
</section>\
</div>";

// js 脚本
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
p{max-width:100%;height:auto}\
div{max-width:100%}\
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

static NSString *confidantEmialStr = @" Sent from MyConfidant, the app for encrypted email.";
static NSString *confidantEmialText = @"Sent from MyConfidant, the app for encrypted email.";


static NSString *confidantHtmlStr = @"<div myconfidantbegin=''><br />\
<br />\
<br />\
<span>Sent from MyConfidant, the app for encrypted email.</span></div>";

static NSString *htmlHead = @"<div style=\"padding-bottom: 20px;\"></div><div><html xmlns=\"http://www.w3.org/1999/xhtml\">\
<head>\
<title></title>\
</head>";

static NSString *powStr = @"type_1,4I9ZEscX7qE+wDhD3upcjFqsJIifbrVAb0h32amY+5+omDkMxzvZhzaIalTBXGUWvzYuPnTkhEq+nlJOOB2W9LluSbX0YCQbQrs2NNBuSH8zQabb4b7Ln6Jtqec2ZklfGY5eRxp9mu5HFPEZq9AmN3hARwOQSnykZ3c/eCkR4TI=";

static NSString *kInitVector = @"AABBCCDDEEFFGGHH";


#define CLIENT_ID @"873428561545-aui4v5nvn6b1dtodnthmmg5q1ci0vski.apps.googleusercontent.com"
#define CLIENT_SECRET @"AIzaSyBEJx4j3x0PnN3GSPZzShHlFm7Y2Wv28Tw"
#define KEYCHAIN_ITEM_NAME @"MailCore OAuth 2.0 Token"

#endif /* CustomMacro_h */
