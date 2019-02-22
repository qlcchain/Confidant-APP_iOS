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
// 数据库表名
#define FRIEND_REQUEST_TABNAME  @"friend_requet_tableName"
// 文件记录表
#define FILE_STATUS_TABNAME     @"file_status_tableName"
#define FRIEND_LIST_TABNAME  @"friend_list_tableName"
// 好友聊天记录表
#define FRIEND_CHAT_TABNAME  @"FRIEND_CHAT_TABNAME"

#define OperationRecord_Table @"OperationRecord_Table"

// 请求超时时间
#define REQEUST_TIME  20
#define RADIUS 3.0f

#define Bugly_AppID @"d22a5845f9"

//#define MAIN_PURPLE_COLOR RGB(44, 44, 44)
#define MAIN_PURPLE_COLOR UIColorFromRGB(0x2B2B2B)
#define MAIN_WHITE_COLOR UIColorFromRGB(0xffffff)
#define SHADOW_COLOR UIColorFromRGB(0x333333)

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

#pragma mark - 通知
static NSString *SOCKET_ON_DISCONNECT_NOTI = @"SOCKET_ON_DISCONNECT_NOTI";
static NSString *SOCKET_ON_CONNECT_NOTI = @"SOCKET_ON_CONNECT_NOTI";
static NSString *SOCKET_DISCONNECT_NOTI =  @"SOCKET_DISCONNECT_NOTI";
// 头像更改通知
static NSString *USER_HEAD_CHANGE_NOTI = @"USER_HEAD_CHANGE_NOTI";
// touch 验证成功
static NSString *TOUCH_MODIFY_SUCCESS_NOTI = @"TOUCH_MODIFY_SUCCESS_NOTI";
#define SOCKET_LOGIN_SUCCESS_NOTI @"SOCKET_LOGIN_SUCCESS_NOTI"
// 处理同意还是拒绝通知
#define DEAL_FRIEND_NOTI @"DEAL_FRIEND_NOTI"
// 好友状态改变通知
#define FRIENT_ONLINE_CHANGE_NOTI @"FRIENT_ONLINE_CHANGE_NOTI"
// 好友列表改变通知
#define FRIEND_LIST_CHANGE_NOTI @"FRIENT_LIST_CHANGE_NOTI"
// 添加好友通知
#define ADD_FRIEND_NOTI @"ADD_FRIEND_NOTI"
// 删除好友成功通知
#define SOCKET_DELETE_FRIEND_SUCCESS_NOTI @"SOCKET_DELETE_FRIEND_SUCCESS_NOTI"
// 好友删除您的通知
#define FRIEND_DELETE_MY_NOTI @"FRIEND_DELETE_MY_NOTI"
// 拉取好友成功通知
#define GET_FRIEND_LIST_NOTI @"GET_FRIEND_LIST_NOTI"
// 添加聊天消息通知
#define ADD_MESSAGE_NOTI @"ADD_MESSAGE_NOTI"
// 添加聊天消息通知
#define RECEIVE_MESSAGE_NOTI @"RECEIVE_MESSAGE_NOTI"
// 聊天消息发送成功通知
#define SEND_CHATMESSAGE_SUCCESS_NOTI @"SEND_CHATMESSAGE_SUCCESS_NOTI"
// 下拉增加聊天消息通知
#define ADD_MESSAGE_BEFORE_NOTI @"ADD_MESSAGE_BEFORE_NOTI"
// 删除消息成功通知
#define DELET_MESSAGE_SUCCESS_NOTI @"DELET_MESSAGE_SUCCESS_NOTI"
// 收到删除某条消息通知
#define RECEIVE_DELET_MESSAGE_NOTI @"RECEIVE_DELET_MESSAGE_NOTI"
// 有人请求加好友通知
#define REQEUST_ADD_FRIEND_NOTI @"REQEUST_ADD_FRIEND_NOTI"
// 对方同意加你为好友通知
#define FRIEND_ACCEPED_NOTI @"FRIEND_ACCEPED_NOTI"
// tabbar Contact 红点通知
#define TABBAR_CONTACT_HD_NOTI @"TABBAR_CONTACT_HD_NOTI"
// tabbar Chats 红点通知
#define TABBAR_CHATS_HD_NOTI @"TABBAR_CHATS_HD_NOTI"
// 自己是否在线的通知
#define OWNER_ONLINE_NOTI @"OWNER_ONLINE_NOTI"
// 选择好友通知
#define CHOOSE_FRIEND_NOTI @"CHOOSE_FRIEND_NOTI"
// 文件发送通知
#define FILE_SEND_NOTI @"FILE_SEND_NOTI"
// 上传文字文件发送通知
#define FILE_UPLOAD_NOTI @"FILE_UPLOAD_NOTI"
// 收到文件发送通知
#define RECEVIE_FILE_NOTI @"RECEVIE_FILE_NOTI"
// 用户找回通知
#define USER_FIND_RECEVIE_NOTI @"USER_FIND_RECEVIE_NOTI"
// 用户注册通知
#define USER_REGISTER_RECEVIE_NOTI @"USER_REGISTER_RECEVIE_NOTI"
// 组禾播接受完通知
#define GB_FINASH_NOTI @"GB_FINASH_NOTI"
// 重连失败通知
#define RELOAD_SOCKET_FAILD_NOTI @"RELOAD_SOCKET_FAILD_NOTI"
// 路由用户列表拉取成功
#define USER_PULL_SUCCESS_NOTI @"USER_PULL_SUCCESS_NOTI"
// tox添加路由好友成功
#define TOX_ADD_ROUTER_SUCCESS_NOTI @"TOX_ADD_ROUTER_SUCCESS_NOTI"
// tox重连成功
#define TOX_RECONNECT_SUCCESS_NOTI @"TOX_RECONNECT_SUCCESS_NOTI"
// 创建普通用户成功
#define CREATE_USER_SUCCESS_NOTI @"TOX_ADD_ROUTER_SUCCESS_NOTI"
// push已读消息
#define REVER_RED_MSG_NOTI @"REVER_RED_MSG_NOTI"
// logout 成功
#define REVER_LOGOUT_SUCCESS_NOTI @"REVER_LOGOUT_SUCCESS_NOTI"
// 修改昵称 成功
#define REVER_UPDATE_NICKNAME_SUCCESS_NOTI @"REVER_UPDATE_NICKNAME_SUCCESS_NOTI"
// 修改好友昵称 成功
#define REVER_UPDATE_FRIEND_NICKNAME_SUCCESS_NOTI @"REVER_UPDATE_FRIEND_NICKNAME_SUCCESS_NOTI"
// 文件发送失败
#define REVER_FILE_SEND_FAIELD_NOTI @"REVER_FILE_SEND_FAIELD_NOTI"
// toxpull文件
#define REVER_FILE_PULL_NOTI @"REVER_FILE_PULL_NOTI"
// toxpull文件完成
#define REVER_FILE_PULL_SUCCESS_NOTI @"REVER_FILE_PULL_SUCCESS_NOTI"
// 注册推送通知
#define REGISTER_PUSH_NOTI @"REGISTER_PUSH_NOTI"
#define REVER_QUERY_FRIEND_NOTI @"REVER_QUERY_FRIEND_NOTI"
// app登出通知
#define REVER_APP_LOGOUT_NOTI @"REVER_APP_LOGOUT_NOTI"
// 设备登录成功通知
#define DEVICE_LOGIN_SUCCESS_NOTI @"DEVICE_LOGIN_SUCCESS_NOTI"
// 修改管理密码成功通知
#define ResetRouterKey_SUCCESS_NOTI @"ResetRouterKey_SUCCESS_NOTI"
// 修改账户激活码成功通知
#define ResetUserIdcode_SUCCESS_NOTI @"ResetUserIdcode_SUCCESS_NOTI"
// 取消登陆mac
#define CANCEL_LOGINMAC_NOTI @"CANCEL_LOGINMAC_NOTI"
// 拉取文件列表完成通知
#define PullFileList_Complete_Noti @"PullFileList_Complete_Noti"
// 上传文件请求完成通知
#define UploadFileReq_Success_Noti @"UploadFileReq_Success_Noti"
// 选择分享好友列表完成通知
#define CHOOSE_Share_FRIEND_NOTI @"CHOOSE_Share_FRIEND_NOTI"
// 拉取可分享文件好友列表成功通知
#define PullSharedFriend_Noti @"PullSharedFriend_Noti"
// 获取设备磁盘统计信息成功通知
#define GetDiskTotalInfo_Noti @"GetDiskTotalInfo_Noti"
// 获取设备磁盘详细信息成功通知
#define GetDiskDetailInfo_Noti @"GetDiskDetailInfo_Noti"
// 设备磁盘模式配置成功通知
#define FormatDisk_Success_Noti @"FormatDisk_Success_Noti"
#define FormatDisk_Fail_Noti @"FormatDisk_Fail_Noti"
// 设备重启成功通知
#define Reboot_Success_Noti @"Reboot_Success_Noti"
#define Reboot_Fail_Noti @"Reboot_Fail_Noti"
// 设备管理员修改设备昵称 修改成功通知
#define ResetRouterName_Success_Noti @"ResetRouterName_Success_Noti"

// 删除文件成功通知
#define Delete_File_Noti @"Delete_File_Noti"
// 文件上传进度通知
#define File_Progess_Noti @"File_Progess_Noti"
// tox下载进度通知
#define Tox_Down_File_Progess_Noti @"Tox_Down_File_Progess_Noti"
// 文件上传成功通知
#define File_Upload_Finsh_Noti @"File_Upload_Finsh_Noti"
// 文件上传失败通知
#define File_Upload_Faield_Noti @"File_Upload_Faield_Noti"
// 任务列表tox拉取文件
#define TOX_PULL_FILE_FAIELD_NOTI @"TOX_PULL_FILE_FAIELD_NOTI"
#define TOX_PULL_FILE_SUCCESS_NOTI @"TOX_PULL_FILE_SUCCESS_NOTI"
// tox 断线状态通知
#define TOX_CONNECT_STATUS_NOTI  @"TOX_CONNECT_STATUS_NOTI"
#endif /* CustomMacro_h */
