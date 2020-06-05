//
//  CustomMacro.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/10.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#ifndef NotiMacro_h
#define NotiMacro_h

#pragma mark - 通知
static NSString *SOCKET_ON_DISCONNECT_NOTI = @"SOCKET_ON_DISCONNECT_NOTI";
static NSString *SOCKET_ON_CONNECT_NOTI = @"SOCKET_ON_CONNECT_NOTI";
static NSString *SOCKET_DISCONNECT_NOTI =  @"SOCKET_DISCONNECT_NOTI";
// 头像更改通知
static NSString *USER_HEAD_CHANGE_NOTI = @"USER_HEAD_CHANGE_NOTI";
// 正在下载
static NSString *DID_DOWN_FILE_NOTI = @"DID_DOWN_FILE_NOTI";
// 正在下载
static NSString *DID_UPLOAD_FILE_NOTI = @"DID_UPLOAD_FILE_NOTI";
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
// 拉取好友失败通知
#define GET_FRIEND_LIST_FAILED_NOTI @"GET_FRIEND_LIST_FAILED_NOTI"
// 拉取好友和群聊通知
#define GET_FRIEND_GROUP_LIST_NOTI @"GET_FRIEND_GROUP_LIST_NOTI"
// 切换圈子成功通知
#define SWITCH_CIRCLE_SUCCESS_NOTI @"SWITCH_CIRCLE_SUCCESS_NOTI"
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
// 新用户注册默认添加节点管理员 在chat界面
#define ADD_OWNER_CHAT_NOTI @"ADD_OWNER_CHAT_NOTI"
// 选择好友通知
#define CHOOSE_FRIEND_CREATE_GROUOP_NOTI @"CHOOSE_FRIEND_CREATE_GROUOP_NOTI"
// chats界面选择好友
#define CHAT_CHOOSE_FRIEND_CREATE_GROUOP_NOTI @"CHAT_CHOOSE_FRIEND_CREATE_GROUOP_NOTI"
#define EMAIL_CHOOSE_FRIEND_SEND_NOTI @"EMAIL_CHOOSE_FRIEND_SEND_NOTI"
#define CHOOSE_FRIEND_FOWARD_NOTI @"CHOOSE_FRIEND_FOWARD_NOTI"
#define CHOOSE_FRIEND_FILE_FOWARD_NOTI @"CHOOSE_FRIEND_FILE_FOWARD_NOTI"
// 外部文件转发选择好友通知
#define DOC_OPEN_CHOOSE_FRIEND_NOTI @"DOC_OPEN_CHOOSE_FRIEND_NOTI"
// 文件发送通知
#define FILE_SEND_NOTI @"FILE_SEND_NOTI"
// 文件发送中通知
#define FILE_SENDING_NOTI @"FILE_SENDING_NOTI"
// 上传文字文件发送通知
#define FILE_UPLOAD_NOTI @"FILE_UPLOAD_NOTI"
// 上传头像发送通知
#define UPLOAD_HEAD_DATA_NOTI @"UPLOAD_HEAD_DATA_NOTI"
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
// 文件重命名
#define FileRename_Success_Noti @"FileRename_Success_Noti"
// 用户上传头像
#define UploadAvatar_Success_Noti @"UploadAvatar_Success_Noti"
// 更新用户头像
#define UpdateAvatar_Success_Noti @"UpdateAvatar_Success_Noti"
// 更新用户头像：头像不存在
#define UpdateAvatar_FileNotExist_Noti @"UpdateAvatar_FileNotExist_Noti"
// 拉取临时通信二维码  成功通知
#define PullTmpAccount_Success_Noti @"PullTmpAccount_Success_Noti"
// 外部文件打开
#define OTHER_FILE_OPEN_NOTI @"OTHER_FILE_OPEN_NOTI"
// 删除用户成功
#define DEL_USER_SUCCESS_NOTI @"DEL_USER_SUCCESS_NOTI"
// 配置节点成功
#define ENABLE_QLC_NODE_SUCCESS_NOTI @"ENABLE_QLC_NODE_SUCCESS_NOTI"
// 检查节点是否开启
#define CHECK_QLC_NODE_SUCCESS_NOTI @"CHECK_QLC_NODE_SUCCESS_NOTI"
// @选中人
#define REMIND_USER_SUCCESS_NOTI @"REMIND_USER_SUCCESS_NOTI"

// ---------------------邮件----------------------
#define EMIAL_LOGIN_SUCCESS_NOTI  @"EMIAL_LOGIN_SUCCESS_NOTI"
#define EMIAL_ACCOUNT_CHANGE_NOTI  @"EMIAL_ACCOUNT_CHANGE_NOTI"
#define EMAIL_CONFIG_NOTI  @"EMAIL_CONFIG_NOTI"
#define EMAIL_GETKEY_NOTI  @"EMAIL_GETKEY_NOTI"
#define EMAIL_NODE_COUNT_NOTI  @"EMAIL_NODE_COUNT_NOTI"
#define EMAIL_NODE_UPLOAD_NOTI  @"EMAIL_NODE_UPLOAD_NOTI"
#define EMAIL_PULL_NODE_NOTI  @"EMAIL_PULL_NODE_NOTI"
#define EMAIL_DEL_NODE_NOTI  @"EMAIL_DEL_NODE_NOTI"
#define EMAIL_DEL_CONFIG_NOTI  @"EMAIL_DEL_CONFIG_NOTI"
#define EMAIL_DEL_CONFIG_SUCCESS_NOTI  @"EMAIL_DEL_CONFIG_SUCCESS_NOTI"
#define SEARCH_MODEL_STATUS_CHANGE_NOTI  @"SEARCH_MODEL_STATUS_CHANGE_NOTI"
#define EMAIL_NO_CONFIG_NOTI  @"EMAIL_NO_CONFIG_NOTI"
#define EMAIL_ENTRYPED_CHOOSE_NOTI @"EMAIL_ENTRYPED_CHOOSE_NOTI"
#define EMAIL_BAK_NODE_NOTI @"EMAIL_BAK_NODE_NOTI"

// 0 未读 1 加星 2 移动 3 删除
#define EMIAL_FLAGS_CHANGE_NOTI  @"EMIAL_FLAGS_CHANGE_NOTI"
// 最近联系人选白择
#define EMIAL_CONTACT_SEL_NOTI  @"EMIAL_CONTACT_SEL_NOTI"
// 保存到节点完成通知
#define EMIAL_UPLOAD_NODE_NOTI  @"EMIAL_UPLOAD_NODE_NOTI"

// ---------------------群组----------------------
#define CREATE_GROUP_SUCCESS_NOTI  @"CREATE_GROUP_SUCCESS_NOTI"
// chat
#define CHAT_CREATE_GROUP_SUCCESS_JUMP_NOTI  @"CHAT_CREATE_GROUP_SUCCESS_JUMP_NOTI"
// add
#define ADD_CREATE_GROUP_SUCCESS_JUMP_NOTI  @"ADD_CREATE_GROUP_SUCCESS_JUMP_NOTI"
// groups
#define GROUPS_CREATE_GROUP_SUCCESS_JUMP_NOTI  @"GROUPS_CREATE_GROUP_SUCCESS_JUMP_NOTI"
// 拉取群列表成功
#define PULL_GROUP_SUCCESS_NOTI @"PULL_GROUP_SUCCESS_NOTI"
// 拉取群列表失败
#define PULL_GROUP_FAILED_NOTI @"PULL_GROUP_FAILED_NOTI"
// 拉取群好友信息成功通知
#define GroupUserPull_SUCCESS_NOTI @"GroupUserPull_SUCCESS_NOTI"
// 拉取群好友信息失败通知
#define GroupUserPull_FAILED_NOTI @"GroupUserPull_FAILED_NOTI"
// 加入群组成功
#define ADD_GROUP_SUCCESS_NOTI @"ADD_GROUP_SUCCESS_NOTI"
// 群聊消息发送成功
#define GROUP_MESSAGE_SEND_SUCCESS_NOTI @"GROUP_MESSAGE_SEND_SUCCESS_NOTI"
// 拉取群聊消息列表
#define PULL_GROUP_MESSAGE_SUCCESS_NOTI @"PULL_GROUP_MESSAGE_SUCCESS_NOTI"
// 收到群消息推送
#define RECEVIED_GROUP_MESSAGE_SUCCESS_NOTI @"RECEVIED_GROUP_MESSAGE_SUCCESS_NOTI"
// 收到群系统消息推送
#define RECEVIED_GROUP_SYSMSG_SUCCESS_NOTI @"RECEVIED_GROUP_SYSMSG_SUCCESS_NOTI"
// 删除群消息
#define RECEVIED_Del_GROUP_MESSAGE_SUCCESS_NOTI @"RECEVIED_Del_GROUP_MESSAGE_SUCCESS_NOTI"
// 修改群别名成功通知
#define Revise_Group_Alias_SUCCESS_NOTI @"Revise_Group_Alias_SUCCESS_NOTI"
// 修改群名称成功通知
#define Revise_Group_Name_SUCCESS_NOTI @"Revise_Group_Name_SUCCESS_NOTI"
// 用户退群成功通知
#define GroupQuit_SUCCESS_NOTI @"GroupQuit_SUCCESS_NOTI"
// 设置审核邀请成功通知
#define Set_Approve_Invitations_SUCCESS_NOTI @"Set_Approve_Invitations_SUCCESS_NOTI"
// 设置审核邀请失败通知
#define Set_Approve_Invitations_FAIL_NOTI @"Set_Approve_Invitations_FAIL_NOTI"
// 踢出某个用户成功通知
#define Remove_Group_Member_SUCCESS_NOTI @"Remove_Group_Member_SUCCESS_NOTI"
// 群组文件发送成功或失败通知
#define GROUP_FILE_SEND_FAIELD_NOTI @"GROUP_FILE_SEND_FAIELD_NOTI"
#define GROUP_FILE_SEND_SUCCESS_NOTI @"GROUP_FILE_SEND_SUCCESS_NOTI"
// 65.    邀请用户入群审核推送通知
#define GroupVerify_Push_NOTI @"GroupVerify_Push_NOTI"
// 66.    邀请用户入群审核处理----成功通知
#define GroupVerify_SUCCESS_NOTI @"GroupVerify_SUCCESS_NOTI"
// toxpull文件完成
#define REVER_GROUP_FILE_PULL_SUCCESS_NOTI @"REVER_GROUP_FILE_PULL_SUCCESS_NOTI"
// 更新消息列表数据通知
#define MessageList_Update_Noti @"MessageList_Update_Noti"

#pragma mark --------------加密相册
#define Pull_Floder_List_Noti @"Pull_Floder_List_Noti"
#define Create_Floder_Success_Noti @"Create_Floder_Success_Noti"
#define Photo_File_Upload_Success_Noti @"Photo_File_Upload_Success_Noti"
#define Pull_Floder_File_List_Noti @"Pull_Floder_File_List_Noti"
#define Photo_Upload_FileData_Noti @"Photo_Upload_FileData_Noti"
#define Photo_Select_Floder_Noti @"Photo_Select_Floder_Noti"
#define Photo_FileData_Upload_Progress_Noti @"Photo_FileData_Upload_Progress_Noti"

#pragma mark------------加密通讯录
#define Upload_Contacts_Data_Error_Noti @"Upload_Contacts_Data_Error_Noti"
#define Upload_Contacts_Data_Success_Noti @"Upload_Contacts_Data_Success_Noti"
#define Pull_BookInfo_Success_Noti @"Pull_BookInfo_Success_Noti"
#define Update_Loacl_Contact_Count_Noti @"Update_Loacl_Contact_Count_Noti"

#pragma mark----------推广活动
#define BakWalletAccount_Noti @"BakWalletAccount_Noti"
#define GetWalletAccount_Noti @"GetWalletAccount_Noti"
//#define SetMyPushRead_Noti    @"SetMyPushRead_Noti"
//#define GetMyPushsList_Noti   @"GetMyPushsList_Noti"

#pragma mark----------意见返馈
#define Feedback_Type_Select_Noti @"Feedback_Type_Select_Noti"
#define Feedback_Add_Success_Noti @"Feedback_Add_Success_Noti"


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
// 头像下载成功通知
#define USER_HEAD_DOWN_SUCCESS_NOTI  @"USER_HEAD_DOWN_SUCCESS_NOTI"

// email
#define GOOGLE_EMAIL_SIGN_SUCCESS_NOTI  @"GOOGLE_EMAIL_SIGN_SUCCESS_NOTI"
#define GOOGLE_EMAIL_SIGN_FAIELD_NOTI  @"GOOGLE_EMAIL_SIGN_FAIELD_NOTI"

#endif /* CustomMacro_h */
