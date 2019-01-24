//
//  MyFilesViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "MyFilesViewController.h"
#import "MyFilesCell.h"
#import "DetailInformationViewController.h"
#import "FilePreviewViewController.h"
#import "ArrangeAlertView.h"
#import "FileMoreAlertView.h"

@interface MyFilesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *sourceArr;
@property (weak, nonatomic) IBOutlet UITableView *mainTable;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (nonatomic) ArrangeType arrangeType;

@end

@implementation MyFilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self dataInit];
}

#pragma mark - Operation
- (void)dataInit {
    if (_filesType == FilesTypeMy) {
        _titleLab.text = @"My Files";
    } else if (_filesType == FilesTypeShare) {
        _titleLab.text = @"Documents I Share";
    } else if (_filesType == FilesTypeReceived) {
        _titleLab.text = @"Documents Received";
    }
    
    _sourceArr = [NSMutableArray array];
    _arrangeType = ArrangeTypeByName;
    
    [_mainTable registerNib:[UINib nibWithNibName:MyFilesCellReuse bundle:nil] forCellReuseIdentifier:MyFilesCellReuse];
}

- (void)showArrangeAlertView {
    ArrangeAlertView *view = [ArrangeAlertView getInstance];
    @weakify_self
    [view setClickB:^(ArrangeType type) {
        weakSelf.arrangeType = type;
        if (type == ArrangeTypeByName) {
            
        } else if (type == ArrangeTypeByTime) {
            
        } else if (type == ArrangeTypeBySize) {
            
        }
    }];
    [view showWithArrange:_arrangeType];
}

- (void)showFileMoreAlertView {
    FileMoreAlertView *view = [[FileMoreAlertView alloc] init];
    @weakify_self
    [view setSendB:^{
        
    }];
    [view setDownloadB:^{
        
    }];
    [view setOtherApplicationOpenB:^{
        
    }];
    [view setDetailInformationB:^{
        [weakSelf jumpToDetailInformation];
    }];
    [view setRenameB:^{
        
    }];
    [view setDeleteB:^{
        
    }];
    
    [view show];
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)multiSelectAction:(id)sender {
    
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return MyFilesCellHeight;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MyFilesCell *cell = [tableView dequeueReusableCellWithIdentifier:MyFilesCellReuse];
    
    //    [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:65.f];
    //    cell.delegate = (id)self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self jumpToFilePreview];
    
}

#pragma mark - Transition
- (void)jumpToDetailInformation {
    DetailInformationViewController *vc = [[DetailInformationViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToFilePreview {
    FilePreviewViewController *vc = [[FilePreviewViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
