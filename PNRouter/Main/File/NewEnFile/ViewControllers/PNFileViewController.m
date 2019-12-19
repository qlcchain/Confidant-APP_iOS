//
//  PNFileViewController.m
//  MyConfidant
//
//  Created by 旷自辉 on 2019/11/20.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNFileViewController.h"
#import "EnMainCell.h"
#import "PNPhotoViewController.h"
#import "PNMessageViewController.h"
#import "UploadFileManager.h"
#import "FingerprintVerificationUtil.h"

@interface PNFileViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *mainTabView;

@end

@implementation PNFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = MAIN_GRAY_COLOR;
    
    // 开启手势
    [FingerprintVerificationUtil checkFloderShow];
    
    // 开启上传文件监听单例
    [UploadFileManager getShareObject];
    
    _mainTabView.delegate = self;
    _mainTabView.dataSource = self;
    _mainTabView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [_mainTabView registerNib:[UINib nibWithNibName:EnMainCellResue bundle:nil] forCellReuseIdentifier:EnMainCellResue];
}


#pragma mark -----------------tableview deleate ---------------------
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return EnMainCellHeight;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EnMainCell *myCell = [tableView dequeueReusableCellWithIdentifier:EnMainCellResue];
    return myCell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) { // 加密相册
        PNPhotoViewController *vc = [[PNPhotoViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.row == 1) { // 加密消息
        PNMessageViewController *vc = [[PNMessageViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
   
}
@end
