//
//  DebugLogViewController.m
//  Qlink
//
//  Created by Jelly Foo on 2018/4/16.
//  Copyright © 2018年 pan. All rights reserved.
//

#import "DebugLogViewController.h"
#import "DDLogUtil.h"
#import "CSLogger.h"

@interface DebugLogViewController ()

@property (weak, nonatomic) IBOutlet UITextView *mainTextV;

@end

@implementation DebugLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self refreshLog];
}


- (void)refreshLog {
    @weakify_self
    if (_inputType == DebugLogTypeSystem) {
        [DDLogUtil getDDLogStr:^(NSString *text) {
            weakSelf.mainTextV.text = text;
            [weakSelf scrollToBottom];
        }];
    } else if (_inputType == DebugLogTypeTest1000) {
        [DDLogUtil getDDLogTest1000Str:^(NSString *text) {
            weakSelf.mainTextV.text = text;
            [weakSelf scrollToBottom];
        }];
    }
}

- (void)scrollToBottom {
    _mainTextV.layoutManager.allowsNonContiguousLayout = NO;
    [_mainTextV scrollRangeToVisible:NSMakeRange(_mainTextV.text.length, 1)];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)updateAction:(id)sender {
    [self refreshLog];
}

- (IBAction)backAction:(id)sender {
    [self back];
}

- (IBAction)clearAction:(id)sender {
//    [[DDLog sharedInstance] removeAllLoggers]; // 移除log
    
    NSArray <NSString *>*logsNameArray = [NSArray array];
    NSString *logsDirectory = nil;
    if (_inputType == DebugLogTypeSystem) {
        DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
        //    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
        logsDirectory = [fileLogger.logFileManager logsDirectory];
        logsNameArray = [fileLogger.logFileManager sortedLogFileNames];
    } else if (_inputType == DebugLogTypeTest1000) {
        logsDirectory = [CSFileLogger getLogsDir:CS_Test_1000];
        logsNameArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:logsDirectory error:nil];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // log文件按时间排序
        NSArray *sortArr = [logsNameArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return NSOrderedDescending;
        }];
        
        // log文件路径
        [sortArr enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *logPath = [logsDirectory stringByAppendingPathComponent:obj];
            BOOL removeSuccess = [[NSFileManager defaultManager] removeItemAtPath:logPath error:nil];
            NSLog(@"removeSuccess=%@",@(removeSuccess));
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshLog];
        });
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
