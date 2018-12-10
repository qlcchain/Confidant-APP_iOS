//
//  FileDynamicsViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2018/10/8.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "FileDynamicsViewController.h"
#import "FileDynamicsCell.h"
#import "YWFilePreviewController.h"
#import "YWFilePreviewView.h"

@interface FileDynamicsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *mainTable;
@property (nonatomic, strong) NSMutableArray *sourceArr;

@end

@implementation FileDynamicsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sourceArr = [NSMutableArray array];
    _mainTable.delegate = self;
    _mainTable.dataSource = self;
    _mainTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _mainTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_mainTable registerNib:[UINib nibWithNibName:FileDynamicsCellReuse bundle:nil] forCellReuseIdentifier:FileDynamicsCellReuse];
}

#pragma mark - TableviewDataSourceDelegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
    return _sourceArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return FileDynamicsCellHeight;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 16;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 16)];
    backView.backgroundColor = [UIColor clearColor];
    return backView;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FileDynamicsCell *cell = [tableView dequeueReusableCellWithIdentifier:FileDynamicsCellReuse];
//    NSArray *rowArr = [self.dataArray objectAtIndex:indexPath.section];
//    cell.lblContent.text = rowArr[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)filePreviewMultiple {
    NSString *filePath1 = [[NSBundle mainBundle] pathForResource:@"1.xlsx" ofType:nil ];
    NSString *filePath2 = [[NSBundle mainBundle] pathForResource:@"2.docx" ofType:nil ];
    NSString *filePath3 = [[NSBundle mainBundle] pathForResource:@"3.ppt" ofType:nil ];
    NSString *filePath4 = [[NSBundle mainBundle] pathForResource:@"4.pdf" ofType:nil ];
    NSString *filePath5 = [[NSBundle mainBundle] pathForResource:@"5.png" ofType:nil ];
    NSString *filePath6 = [[NSBundle mainBundle] pathForResource:@"EBMute.mp3" ofType:nil];
    NSString *filePath7 = [[NSBundle mainBundle] pathForResource:@"11111.mp4" ofType:nil];
    
    NSArray *filePathArr = @[filePath2,filePath1, filePath3, filePath4, filePath5,filePath6,filePath7];
    
    YWFilePreviewController *_filePreview = [[YWFilePreviewController alloc] init];
    
    [_filePreview previewFileWithPaths:filePathArr on:self jump:YWJumpPresentAnimat];
}

- (IBAction)filePreviewSimple {
    NSString *filePath4 = [[NSBundle mainBundle] pathForResource:@"4.pdf" ofType:nil ];
    
    [YWFilePreviewView previewFileWithPaths:filePath4 fileName:@"" fileType:1];
    
}

@end
