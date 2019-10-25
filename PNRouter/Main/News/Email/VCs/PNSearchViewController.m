//
//  PNSearchViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/8/8.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNSearchViewController.h"
#import "ChatListModel.h"
#import "EmailListInfo.h"
#import "EmailListCell.h"
#import "NewsCell.h"
#import "NSDate+Category.h"
#import "PNDefaultHeaderView.h"
#import "EmailOptionUtil.h"
#import "GroupInfoModel.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "GroupChatViewController.h"
#import "FriendModel.h"
#import "UserConfig.h"
#import "ChatViewController.h"
#import "PNEmailSendViewController.h"
#import "PNEmailDetailViewController.h"
#import "FloderModel.h"
#import "GoogleMessageModel.h"

@interface PNSearchViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
    {
        NSInteger selRow;
    }
@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (weak, nonatomic) IBOutlet UITableView *mainTabView;

@property (nonatomic, strong) NSMutableArray *searchData;
@property (nonatomic, strong) NSMutableArray *allData;
    @property (nonatomic, strong) FloderModel *floderM;
@property (nonatomic, assign) BOOL isMessage;

    
@end

@implementation PNSearchViewController
- (void)dealloc
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
- (IBAction)clickCancelAction:(id)sender {
    [self leftNavBarItemPressedWithPop:NO];
}
- (instancetype)initWithData:(NSMutableArray *) dataArr isMessage:(BOOL) isM floder:(FloderModel *)fm
{
    if (self = [super init]) {
        [self.allData addObjectsFromArray:dataArr];
        self.isMessage = isM;
        self.floderM = fm;
    }
    return self;
}
- (NSMutableArray *)searchData
{
    if (!_searchData) {
        _searchData = [NSMutableArray array];
    }
    return _searchData;
}
- (NSMutableArray *)allData
{
    if (!_allData) {
        _allData = [NSMutableArray array];
    }
    return _allData;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = MAIN_GRAY_COLOR;
    
    _searchTF.delegate = self;
    _searchTF.enablesReturnKeyAutomatically = YES; //这里设置为无文字就灰色不可点
    _searchTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self addTargetMethod];
    
    _mainTabView.delegate = self;
    _mainTabView.dataSource = self;
    _mainTabView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (self.isMessage) {
        [_mainTabView registerNib:[UINib nibWithNibName:NewsCellResue bundle:nil] forCellReuseIdentifier:NewsCellResue];
    } else {
        [_mainTabView registerNib:[UINib nibWithNibName:EmailListCellResue bundle:nil] forCellReuseIdentifier:EmailListCellResue];
    }
    
    
    [self performSelector:@selector(becomeSearchTF) withObject:self afterDelay:0.7];
    
    // 邮件flags 改变通知
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailFlagsChangeNoti:) name:EMIAL_FLAGS_CHANGE_NOTI object:nil];
}
- (void) becomeSearchTF
{
    [_searchTF becomeFirstResponder];
}


#pragma mark - tableviewDataSourceDelegate
    
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isMessage) {
        return NewsCellHeight;
    }
    return EmailListCellHeight;
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if (self.isMessage) {
        NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:NewsCellResue];
        ChatListModel *model = self.searchData[indexPath.row];
        [cell setModeWithChatListModel:model];
        //[cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:65.f];
       // cell.delegate = self;
       // cell.tag = indexPath.row;
        return cell;
    } else {
        EmailListCell *cell = [tableView dequeueReusableCellWithIdentifier:EmailListCellResue];
        if ([self.searchData[indexPath.row] isKindOfClass:[EmailListInfo class]]) {
            EmailListInfo *listInfo = self.searchData[indexPath.row];
            listInfo.currentRow = indexPath.row;
            cell.lblTtile.text = listInfo.fromName?:@"";
            cell.lblSubTitle.text = listInfo.Subject?:@"";
            cell.lblTime.text = [listInfo.revDate minuteDescription];
            UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:@"" Name:[StringUtil getUserNameFirstWithName:cell.lblTtile.text]];
            cell.headImgView.image = defaultImg;
            if (listInfo.Read %2 == 0 && ![self.floderM.name isEqualToString:Drafts] && ![self.floderM.name isEqualToString:Sent]) {
                cell.readView.hidden = NO;
                cell.lblContent.textColor = MAIN_PURPLE_COLOR;
            } else {
                cell.readView.hidden = YES;
                cell.lblContent.textColor = RGB(148, 150, 161);
            }
            // 获取read 二进制的第三位，1为加星  0 为没有
            cell.lableImgView.hidden = ![EmailOptionUtil checkEmailStar:listInfo.Read];
            cell.starW.constant = cell.lableImgView.hidden? 0:24;
            
            if (listInfo.deKey && listInfo.deKey.length > 0 && ![self.floderM.name isEqualToString:Node_backed_up]) {
                cell.lockImgView.hidden = NO;
            } else {
                cell.lockImgView.hidden = YES;
            }
            
            cell.lblContent.text = listInfo.content;
            if (listInfo.attachCount == 0) {
                cell.attachImgView.hidden = YES;
                cell.lblAttCount.text = @"";
            } else {
                cell.attachImgView.hidden = NO;
                cell.lblAttCount.text = [NSString stringWithFormat:@"%d",listInfo.attachCount];
            }
        } else {
            GoogleMessageModel *messageM = self.searchData[indexPath.row];
            
            cell.lblContent.text = messageM.snippet?:@"";
            cell.lblTime.text = [[NSDate dateWithTimeIntervalSince1970:messageM.internalDate/1000] minuteDescription];
            cell.lblSubTitle.text = messageM.Subject?:@"";
            
            
            cell.lblTtile.text = messageM.FromName?:@"";
            UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:@"" Name:[StringUtil getUserNameFirstWithName:cell.lblTtile.text]];
            cell.headImgView.image = defaultImg;
            
            if (messageM.attachCount == 0) {
                cell.attachImgView.hidden = YES;
                cell.lblAttCount.text = @"";
            } else {
                cell.attachImgView.hidden = NO;
                cell.lblAttCount.text = [NSString stringWithFormat:@"%d",messageM.attachCount];
            }
            
            // 星标
            
            cell.lableImgView.hidden = !messageM.isStarred;
            cell.starW.constant = cell.lableImgView.hidden? 0:24;
            
            if (messageM.deKey && messageM.deKey.length > 0 && ![self.floderM.name isEqualToString:Node_backed_up]) {
                cell.lockImgView.hidden = NO;
            } else {
                cell.lockImgView.hidden = YES;
            }
            
            if (!messageM.isRead && ![self.floderM.name isEqualToString:Drafts] && ![self.floderM.name isEqualToString:Sent]) {
                cell.readView.hidden = NO;
                cell.lblContent.textColor = MAIN_PURPLE_COLOR;
            } else {
                cell.readView.hidden = YES;
                cell.lblContent.textColor = RGB(148, 150, 161);
            }
            
        }
       
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
    {
        [self.view endEditing:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        id object = self.searchData[indexPath.row];
        @weakify_self
        [self dismissViewControllerAnimated:YES completion:^{
            if (weakSelf.clickObjBlock) {
                weakSelf.clickObjBlock(object);
            }
        }];
       
        return;
        
        if (self.isMessage) {
            if (!tableView.isEditing) {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                ChatListModel *chatModel = self.searchData[indexPath.row];
                
                if (chatModel.isHD) {
                    chatModel.isHD = NO;
                    chatModel.unReadNum = @(0);
                    [chatModel bg_saveOrUpdate];
                    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    [[NSNotificationCenter defaultCenter] postNotificationName:TABBAR_CHATS_HD_NOTI object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:SEARCH_MODEL_STATUS_CHANGE_NOTI object:nil];
                }
                if (chatModel.isGroup) {
                    GroupInfoModel *model = [[GroupInfoModel alloc] init];
                    model.GId = chatModel.groupID;
                    model.GName = [chatModel.groupName base64EncodedString];
                    model.Remark = [chatModel.groupAlias base64EncodedString];
                    model.UserKey = chatModel.groupUserkey;
                    
                    GroupChatViewController *vc = [[GroupChatViewController alloc] initWihtGroupMode:model];
                    [self.navigationController pushViewController:vc animated:YES];
                } else {
                    FriendModel *model = [[FriendModel alloc] init];
                    model.userId = chatModel.friendID;
                    model.owerId = [UserConfig getShareObject].userId;
                    model.username = chatModel.friendName;
                    model.publicKey = chatModel.publicKey;
                    model.signPublicKey = chatModel.signPublicKey;
                    
                    ChatViewController *vc = [[ChatViewController alloc] initWihtFriendMode:model];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                
            }
        } else {
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            EmailListInfo *model = self.searchData[indexPath.row];
            model.floderName = self.floderM.name;
            model.floderPath = self.floderM.path;
            selRow = indexPath.row;
            
            if ([self.floderM.name isEqualToString:Drafts]) { //草稿箱
                PNEmailSendViewController *vc = [[PNEmailSendViewController alloc] initWithEmailListInfo:model sendType:DraftEmail];
                [self presentModalVC:vc animated:YES];
                
            } else {
                PNEmailDetailViewController *vc = [[PNEmailDetailViewController alloc] initWithEmailListModer:model];
                [self.navigationController pushViewController:vc animated:YES];
                // 设为已读
                if (model.Read == 0) {
                    model.Read = 1;
                    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    // 设为已读
                    [EmailOptionUtil setEmailReaded:YES uid:model.uid messageId:model.messageid folderPath:model.floderPath complete:^(BOOL success) {
                        
                    }];
                    [[NSNotificationCenter defaultCenter] postNotificationName:SEARCH_MODEL_STATUS_CHANGE_NOTI object:nil];
                }
            }
        }
    }

    
    
    
#pragma mark - 直接添加监听方法
-(void)addTargetMethod{
    [_searchTF addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
}
- (void) textFieldTextChange:(UITextField *) tf
{
    [self.searchData removeAllObjects];
    @weakify_self
    [self.allData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (weakSelf.isMessage) {
            ChatListModel *model = obj;
            NSString *userName = model.isGroup?[model.groupShowName lowercaseString]:[model.friendName lowercaseString];
            if ([userName containsString:[tf.text.trim lowercaseString]]) {
                [weakSelf.searchData addObject:model];
            }
        } else {
            NSString *userName = @"";
            NSString *userAddress = @"";
            NSString *content = @"";
            if ([obj isKindOfClass:[EmailListInfo class]]) {
                EmailListInfo *model = obj;
                userName = [model.fromName lowercaseString];
                userAddress = [model.Subject lowercaseString];
                content = [model.content lowercaseString];
            } else {
                GoogleMessageModel *model = obj;
                userName = [model.FromName lowercaseString];
                userAddress = [model.Subject lowercaseString];
                content = [model.snippet lowercaseString];
            }
            
            
            if ([userName containsString:[tf.text.trim lowercaseString]] || [userAddress containsString:[tf.text.trim lowercaseString]] || [content containsString:[tf.text.trim lowercaseString]]) {
                [weakSelf.searchData addObject:obj];
            }
        }
    }];
    [_mainTabView reloadData];
}


    // 邮件flags改变
- (void) emailFlagsChangeNoti:(NSNotification *) noti
    {
        int optionType = [noti.object intValue];
        if (optionType == 0 || optionType == 1) { // 未读 和 加星
            [self.mainTabView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:selRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        } else if (optionType == 2 || optionType == 3) { // 移动到  和 删除
            
            [self.searchData removeObjectAtIndex:selRow];
            [self.mainTabView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:selRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            self.floderM.count--;
        } else if (optionType == 4) { // 星标邮件取消星标
            [self.searchData removeObjectAtIndex:selRow];
            [self.mainTabView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:selRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            self.floderM.count--;
        }
    }
@end
