//
//  PNEmailEditViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/8/9.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNEmailEditViewController.h"
#import "EmailAccountModel.h"
#import "LogOutCell.h"
#import "MyCell.h"
#import "PNEmailLoginViewController.h"
#import "PNEmailConfigViewController.h"
#import "SystemUtil.h"
#import <GoogleSignIn/GoogleSignIn.h>


@interface PNEmailEditViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *typeImgView;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@property (weak, nonatomic) IBOutlet UITableView *mainTabView;

@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation PNEmailEditViewController
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (NSArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = @[@"Configure Email",@"Delete Email"];
    }
    return _dataArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = MAIN_WHITE_COLOR;
   
    NSDictionary *typeNameDic = @{@"1":@"email_icon_qqmailbox",@"2":@"email_icon_qq",@"3":@"email_icon_163",@"4":@"email_icon_google",@"5":@"email_icon_outlook",@"7":@"email_icon_exchange",@"6":@"email_icon_icloud",@"255":@"email_icon_other"};
    
    EmailAccountModel *accountM = [EmailAccountModel getConnectEmailAccount];
    NSString *imgkey = [NSString stringWithFormat:@"%d",accountM.Type];
    _typeImgView.image = [UIImage imageNamed:typeNameDic[imgkey]];
    _lblName.text = [accountM.User componentsSeparatedByString:@"@"][0];
    _lblAddress.text = accountM.User;
    
    _mainTabView.delegate = self;
    _mainTabView.dataSource = self;
    _mainTabView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _mainTabView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_mainTabView registerNib:[UINib nibWithNibName:MyCellReuse bundle:nil] forCellReuseIdentifier:MyCellReuse];
    [_mainTabView registerNib:[UINib nibWithNibName:LogOutCellReuse bundle:nil] forCellReuseIdentifier:LogOutCellReuse];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delEmailConfigNoti:) name:EMAIL_DEL_CONFIG_NOTI object:nil];
    
}
- (IBAction)clickBackAction:(id)sender {
    [self leftNavBarItemPressedWithPop:NO];
}


#pragma mark - tableviewDataSourceDelegate
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 56;
    }
    return LogOutCell_Height;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
     if (indexPath.row == 0) { // 退出登录
         MyCell *cell = [tableView dequeueReusableCellWithIdentifier:MyCellReuse];
         cell.iconWidth.constant = 0;
         cell.iconleftV.constant = 0;
         cell.subBtn.hidden = YES;
         cell.lblContent.text = self.dataArray[indexPath.row];
         return cell;
     } else {
        
        LogOutCell *cell = [tableView dequeueReusableCellWithIdentifier:LogOutCellReuse];
         [cell.logoutBtn setTitle:self.dataArray[indexPath.row] forState:UIControlStateNormal];
         [cell.logoutBtn setTitleColor:TABBAR_RED_COLOR forState:UIControlStateNormal];
        @weakify_self
        cell.logOutB = ^{
            [weakSelf delEmailConfig];
        };
        return cell;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EmailAccountModel *accountM = [EmailAccountModel getConnectEmailAccount];
    if (accountM.Type == 255) {
        PNEmailConfigViewController *vc = [[PNEmailConfigViewController alloc] initWithIsEdit:YES];
        [self presentModalVC:vc animated:YES];
    } else {
        PNEmailLoginViewController *vc = [[PNEmailLoginViewController alloc] initWithEmailType:accountM.Type optionType:ConfigEmail];
        [self presentModalVC:vc animated:YES];
    }
    
}

// 删除邮件
- (void) delEmailConfig
{
    [SendRequestUtil sendEmailDelConfigWithShowHud:YES];
}




#pragma mark -------------------通知回调------------------------
- (void) delEmailConfigNoti:(NSNotification *) noti
{
    NSDictionary *dic = noti.object;
    NSInteger retCode = [dic[@"RetCode"] integerValue];
    if (retCode == 0) { // 成功
        
        //删除当前本地邮箱
        EmailAccountModel *accountM = [EmailAccountModel getConnectEmailAccount];
        
        if (accountM.userId && accountM.userId.length > 0) {
            [[GIDSignIn sharedInstance] signOut];
            AppD.isGoogleSign = NO;
        }
        
        [EmailAccountModel deleteEmailWithUser:accountM.User];
        // 删除本地附件---
        [SystemUtil removeDocmentFilePath:[SystemUtil getDocEmailBasePath]];
        // 更新第一个为选中
        [EmailAccountModel updateFirstEmailConnect];
        // 发送删除成功通知
        [[NSNotificationCenter defaultCenter] postNotificationName:EMAIL_DEL_CONFIG_SUCCESS_NOTI object:nil];
        [self leftNavBarItemPressedWithPop:NO];
        
        [AppD.window showHint:Delete_Success_Str];
    } else {
        [self.view showFaieldHudInView:self.view hint:Delete_Failed];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
