//
//  FileViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/10.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "FileViewController.h"
#import "FileCell.h"
#import "TaskListViewController.h"
#import "UploadAlertView.h"
#import "MyFilesViewController.h"

@interface FileViewController ()<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource/*, SWTableViewCellDelegate*/>

//@property (weak, nonatomic) IBOutlet UILabel *fontLab;
@property (weak, nonatomic) IBOutlet UITableView *mainTable;
@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (weak, nonatomic) IBOutlet UIView *searchBackView;

@property (nonatomic, strong) UploadAlertView *uploadAlertV;

@end

@implementation FileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = MAIN_PURPLE_COLOR;
    
    _searchBackView.layer.cornerRadius = 3.0f;
    _searchBackView.layer.masksToBounds = YES;
    _searchTF.delegate = self;
    
    [_mainTable registerNib:[UINib nibWithNibName:FileCellReuse bundle:nil] forCellReuseIdentifier:FileCellReuse];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Operation

- (void)showUploadAlertView {
    _uploadAlertV = [UploadAlertView getInstance];
    [_uploadAlertV setPhotoB:^{
        
    }];
    [_uploadAlertV setVideoB:^{
        
    }];
    [_uploadAlertV setDocumentB:^{
        
    }];
    [_uploadAlertV setOtherB:^{
        
    }];
    [_uploadAlertV show];
}

#pragma mark - Action

- (IBAction)taskAction:(id)sender {
    [self jumpToTaskList];
}

- (IBAction)uploadAction:(id)sender {
    [self showUploadAlertView];
}

- (IBAction)myFileAction:(id)sender {
    [self jumpToMyFile];
}

- (IBAction)shareAction:(id)sender {
    [self jumpToDocumentShare];
}

- (IBAction)receiveAction:(id)sender {
    [self jumpToDocumentReceived];
}



#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return FileCellHeight;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FileCell *cell = [tableView dequeueReusableCellWithIdentifier:FileCellReuse];
    
//    [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:65.f];
//    cell.delegate = (id)self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!tableView.isEditing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

//#pragma mark - SWTableViewDelegate
//- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state {
//    switch (state) {
//        case 0:
//            NSLog(@"utility buttons closed");
//            break;
//        case 1:
//            NSLog(@"left utility buttons open");
//            break;
//        case 2:
//            NSLog(@"right utility buttons open");
//            break;
//        default:
//            break;
//    }
//}
//
//
//- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
//{
//    [cell hideUtilityButtonsAnimated:YES];
//    switch (index) {
//        case 0:
//        {
//            NSLog(@"More button was pressed  1");
//
//            break;
//        }
//        case 1:
//        {
//            NSLog(@"More button was pressed  2");
//            break;
//        }
//        default:
//            break;
//    }
//}
//
//- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
//{
//    // allow just one cell's utility button to be open at once
//    return YES;
//}
//
//- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
//{
//    switch (state) {
//        case 1:
//            // set to NO to disable all left utility buttons appearing
//            return YES;
//            break;
//        case 2:
//            // set to NO to disable all right utility buttons appearing
//            return YES;
//            break;
//        default:
//            break;
//    }
//
//    return YES;
//}
//
//- (NSArray *)rightButtons {
//    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
//    [rightUtilityButtons sw_addUtilityButtonWithColor:
//     MAIN_PURPLE_COLOR
//                                                 icon:[UIImage imageNamed:@"icon_forward"]];
//    [rightUtilityButtons sw_addUtilityButtonWithColor:
//     MAIN_PURPLE_COLOR
//                                                 icon:[UIImage imageNamed:@"icon_right"]];
//    [rightUtilityButtons sw_addUtilityButtonWithColor:
//     MAIN_PURPLE_COLOR
//                                                 icon:[UIImage imageNamed:@"icon_delete"]];
//
//    return rightUtilityButtons;
//}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn");
    return YES;
}

#pragma mark - Transition
- (void)jumpToTaskList {
    TaskListViewController *vc = [[TaskListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToMyFile {
    MyFilesViewController *vc = [[MyFilesViewController alloc] init];
    vc.filesType = FilesTypeMy;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToDocumentShare {
    MyFilesViewController *vc = [[MyFilesViewController alloc] init];
    vc.filesType = FilesTypeShare;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToDocumentReceived {
    MyFilesViewController *vc = [[MyFilesViewController alloc] init];
    vc.filesType = FilesTypeReceived;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
