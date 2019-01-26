//
//  FilePreviewViewController.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/23.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class FileListModel;

@interface FilePreviewDownloadViewController : PNBaseViewController

@property (nonatomic, strong) FileListModel *fileListM;

@end

NS_ASSUME_NONNULL_END
