//
//  DetailInformationViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "DetailInformationViewController.h"
#import "DetailInformationCell.h"
#import "SharedSettingsViewController.h"
#import "FileListModel.h"
#import "MyConfidant-Swift.h"
#import "NSDate+Category.h"
#import "NSString+Base64.h"

@interface DetailInformationShowModel : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *val;
@property (nonatomic) BOOL showArrow;

@end

@implementation DetailInformationShowModel

@end

@interface DetailInformationViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *sourceArr;
@property (nonatomic, strong) IBOutlet UITableView *mainTable;

@end

@implementation DetailInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self dataInit];
}

#pragma mark - Operation
- (void)dataInit {
    _sourceArr = [NSMutableArray array];
    
    DetailInformationShowModel *model = [[DetailInformationShowModel alloc] init];
    model.key = @"File name";
    NSString *fileName = self.fileListM.FileName?:@"";
    model.val = [Base58Util Base58DecodeWithCodeName:fileName];
    model.showArrow = YES;
    [_sourceArr addObject:model];
    model = [[DetailInformationShowModel alloc] init];
    model.key = @"File Type";
    switch ([self.fileListM.FileType integerValue]) {
        case 1:
             model.val = @"JPG";
            break;
        case 2:
            model.val = @"AMR";
            break;
        case 4:
            model.val = @"MP4";
            break;
        case 5:
            model.val = @"DOC";
            break;
        case 6:
            model.val = @"OTHER";
            break;
            
        default:
            break;
    }
   
    model.showArrow = NO;
    [_sourceArr addObject:model];
    model = [[DetailInformationShowModel alloc] init];
    model.key = @"Time created";
    model.val = [NSDate formattedUploadFileTimeFromTimeInterval:[self.fileListM.Timestamp  intValue]];
    model.showArrow = NO;
    [_sourceArr addObject:model];
    model = [[DetailInformationShowModel alloc] init];
    model.key = @"File Size";
    model.val = [NSString stringWithFormat:@"%@KB",self.fileListM.FileSize];
    model.showArrow = NO;
    [_sourceArr addObject:model];
    model = [[DetailInformationShowModel alloc] init];
    model.key = @"File Source";
    model.val = [self.fileListM.Sender base64DecodedString];
    model.showArrow = NO;
    [_sourceArr addObject:model];
   
    
    [_mainTable registerNib:[UINib nibWithNibName:DetailInformationCellReuse bundle:nil] forCellReuseIdentifier:DetailInformationCellReuse];
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DetailInformationCellHeight;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DetailInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:DetailInformationCellReuse];
    DetailInformationShowModel *model = [_sourceArr objectAtIndex:indexPath.row];
    cell.lblTitle.text = model.key;
    cell.lblDesc.text = model.val;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - Transition
- (void)jumpToSharedSettings {
    SharedSettingsViewController *vc = [[SharedSettingsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
