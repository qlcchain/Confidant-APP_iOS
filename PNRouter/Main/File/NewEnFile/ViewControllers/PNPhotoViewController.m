//
//  PNPhotoViewController.m
//  MyConfidant
//
//  Created by 旷自辉 on 2019/11/20.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNPhotoViewController.h"
#import "EnPhotoCell.h"
#import "AddFloderCell.h"
#import "PNFloderContentViewController.h"
#import "KeyBordHeadView.h"
#import <IQKeyboardManager/IQKeyboardManager.h>

@interface PNPhotoViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mainTabView;
@property (nonatomic, strong) KeyBordHeadView *keyHeadView;
@end

@implementation PNPhotoViewController

- (IBAction)clickBackAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}
#pragma mark ---layz
- (KeyBordHeadView *)keyHeadView
{
    if (!_keyHeadView) {
        _keyHeadView = [KeyBordHeadView getKeyBordHeadView];
        _keyHeadView.floderTF.delegate = self;
    }
    return _keyHeadView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = MAIN_GRAY_COLOR;
    
    _mainTabView.delegate = self;
    _mainTabView.dataSource = self;
    _mainTabView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [_mainTabView registerNib:[UINib nibWithNibName:EnPhotoCellResue bundle:nil] forCellReuseIdentifier:EnPhotoCellResue];
    [_mainTabView registerNib:[UINib nibWithNibName:AddFloderCellResue bundle:nil] forCellReuseIdentifier:AddFloderCellResue];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}

// 取消keyboard
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}
// 恢复keyboard
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}

- (void)dealloc {
    //移除键盘监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -----------------tableview deleate ---------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return EnPhotoCellHeight;
    }
    return AddFloderCellHeight;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        EnPhotoCell *myCell = [tableView dequeueReusableCellWithIdentifier:EnPhotoCellResue];
        return myCell;
    } else {
        AddFloderCell *myCell = [tableView dequeueReusableCellWithIdentifier:AddFloderCellResue];
        return myCell;
    }
   
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        PNFloderContentViewController *vc = [[PNFloderContentViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [AppD.window addSubview:self.keyHeadView];
        [self.keyHeadView.floderTF becomeFirstResponder];
    }
    
}

#pragma mark ------------创建文件夹
- (void) createFloderAction
{
    
}


#pragma mark ---点击键盘done
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self createFloderAction];
    return [self.keyHeadView.floderTF resignFirstResponder];
}

#pragma mark ----KeyboardWillShowNotification
- (void) KeyboardWillShowNotification:(NSNotification *) notification
{
    [self.keyHeadView removeFromSuperview];
    self.view.userInteractionEnabled = NO;
    NSDictionary *userInfo = [notification userInfo];
    CGFloat duration = [[userInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    CGRect rect = [[userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"]CGRectValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.keyHeadView.frame = CGRectMake(0, rect.origin.y-163, SCREEN_WIDTH, 163);
    }];
}
- (void) KeyboardWillHideNotification:(NSNotification *) notification
{
    self.view.userInteractionEnabled = YES;
    NSDictionary *userInfo = [notification userInfo];
    CGFloat duration = [[userInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.keyHeadView.frame = CGRectMake(0,SCREEN_HEIGHT, SCREEN_WIDTH, 163);
    }];
}
@end
