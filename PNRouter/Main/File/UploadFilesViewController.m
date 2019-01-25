//
//  UploadFilesViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "UploadFilesViewController.h"
#import "UploadFilesCell.h"
#import "UploadFilesHeaderView.h"
#import "SendRequestUtil.h"
#import "UserConfig.h"
#import "NSString+File.h"
#import "PNRouter-Swift.h"

#define UploadFileURL @"UploadFileURL"

@implementation UploadFilesShowModel

@end

@interface UploadFilesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *sourceArr;
@property (weak, nonatomic) IBOutlet UITableView *mainTable;
@property (weak, nonatomic) IBOutlet UIImageView *fileImg;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLab;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLab;
@property (nonatomic, strong) NSMutableArray *uploadParams;

@end

@implementation UploadFilesViewController

#pragma mark - Observe
- (void)addObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadFileReqSuccessNoti:) name:UploadFileReq_Success_Noti object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self dataInit];
    [self viewInit];
}

#pragma mark - Operation
- (void)dataInit {
    _sourceArr = [NSMutableArray array];
    UploadFilesShowModel *model = [[UploadFilesShowModel alloc] init];
    model.isSelect = NO;
    model.showArrow = NO;
    model.showCell = NO;
    model.title = @"Private Files";
    model.detail = @"Just me";
    model.cellArr = nil;
    [_sourceArr addObject:model];
    
    model = [[UploadFilesShowModel alloc] init];
    model.isSelect = NO;
    model.showArrow = NO;
    model.showCell = NO;
    model.title = @"Public Files";
    model.detail = @"Share with all friends";
    model.cellArr = nil;
    [_sourceArr addObject:model];
    
    model = [[UploadFilesShowModel alloc] init];
    model.isSelect = NO;
    model.showArrow = YES;
    model.showCell = NO;
    model.title = @"Share to";
    model.detail = @"Selected friends";
    model.cellArr = [NSMutableArray array];
    [_sourceArr addObject:model];
    
    model = [[UploadFilesShowModel alloc] init];
    model.isSelect = NO;
    model.showArrow = YES;
    model.showCell = NO;
    model.title = @"Don't share to";
    model.detail = @"Exclude selected friends";
    model.cellArr = [NSMutableArray array];
    [_sourceArr addObject:model];
    
    [_mainTable registerNib:[UINib nibWithNibName:UploadFilesCellReuse bundle:nil] forCellReuseIdentifier:UploadFilesCellReuse];
    [_mainTable registerNib:[UINib nibWithNibName:UploadFilesHeaderViewReuse bundle:nil] forHeaderFooterViewReuseIdentifier:UploadFilesHeaderViewReuse];
}

- (void)viewInit {
    NSString *imgStr = @"";
    NSString *nameStr = @"";
    if (_documentType == DocumentPickerTypePhoto) {
        imgStr = @"icon_picture_gray";
        nameStr = [NSString stringWithFormat:@"Upload Photos (%@)",@(_urlArr.count)];
    } else if (_documentType == DocumentPickerTypeVideo) {
        imgStr = @"icon_video_gray";
        nameStr = [NSString stringWithFormat:@"Upload Videos (%@)",@(_urlArr.count)];
    } else if (_documentType == DocumentPickerTypeDocument) {
        imgStr = @"icon_compress_gray";
        nameStr = [NSString stringWithFormat:@"Upload Documents (%@)",@(_urlArr.count)];
    } else if (_documentType == DocumentPickerTypeOther) {
        imgStr = @"icon_compress_gray";
        nameStr = [NSString stringWithFormat:@"Upload Others (%@)",@(_urlArr.count)];
    }
    _fileImg.image = [UIImage imageNamed:imgStr];
    _fileNameLab.text = nameStr;
    
    __block NSInteger size = 0;
    [_urlArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSURL *fileUrl = obj;
        size += [NSString fileSizeAtPath:fileUrl.path];
    }];
    _fileSizeLab.text = [NSString stringWithFormat:@"%@KB",@(size/1024)];
}

#pragma mark - Action

- (IBAction)cancelAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)uploadAction:(id)sender {
    _uploadParams = [NSMutableArray array];
    @weakify_self
    [_urlArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSURL *url = obj;
        NSString *UserId = [UserConfig getShareObject].userId;
        NSString *FileName = [Base58Util Base58EncodeWithCodeName:url.pathExtension];
        NSNumber *FileSize = @([NSString fileSizeAtPath:url.path]);
        NSNumber *FileType = @(0);
        if (weakSelf.documentType == DocumentPickerTypePhoto) {
            FileType = @(1);
        } else if (weakSelf.documentType == DocumentPickerTypeVideo) {
            FileType = @(4);
        } else if (weakSelf.documentType == DocumentPickerTypeDocument) {
            FileType = @(5);
        } else if (weakSelf.documentType == DocumentPickerTypeOther) {
            FileType = @(6);
        }
        [SendRequestUtil sendUploadFileReqWithUserId:UserId FileName:FileName FileSize:FileSize FileType:FileType showHud:YES fetchParam:^(NSDictionary * _Nonnull dic) {
            NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:dic];
            [muDic setObject:url forKey:UploadFileURL];
            [weakSelf.uploadParams addObject:muDic];
        }];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sourceArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    UploadFilesShowModel *model = _sourceArr[section];
    if (model.showCell) {
        return model.cellArr.count + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UploadFilesCell *cell = [tableView dequeueReusableCellWithIdentifier:UploadFilesCellReuse];
    
    UploadFilesShowModel *model = _sourceArr[indexPath.section];
    if (indexPath.row == 0) {
        
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UploadFilesCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return UploadFilesHeaderViewHeight;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UploadFilesShowModel *model = _sourceArr[section];
    
    UploadFilesHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:UploadFilesHeaderViewReuse];
    [headerView configHeaderWithModel:model];
    @weakify_self
    [headerView setSelectB:^{
        model.isSelect = !model.isSelect;
        [weakSelf.mainTable reloadData];
    }];
    [headerView setShowCellB:^{
        if (model.showArrow) {
            model.showCell = !model.showCell;
            [weakSelf.mainTable reloadData];
        }
    }];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UploadFilesShowModel *model = _sourceArr[indexPath.section];
}

#pragma mark - Noti
- (void)uploadFileReqSuccessNoti:(NSNotification *)noti {
    NSString *msgId = noti.object;
    [_uploadParams enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dic = obj;
        NSString *tempMsgId = dic[@"msgid"];
        if ([tempMsgId isEqualToString:msgId]) {
            //TODO:上传文件
            NSURL *fileUrl = dic[UploadFileURL];
            NSString *filePath = fileUrl.path;
            
            *stop = YES;
        }
    }];
}

@end
