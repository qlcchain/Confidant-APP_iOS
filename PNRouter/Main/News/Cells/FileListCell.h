//
//  FileListCell.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/4/4.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FileListModel;

NS_ASSUME_NONNULL_BEGIN

static NSString *FileListCellResue = @"FileListCell";
#define FileListCellHeight 64

@interface FileListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *fileIconImgV;
@property (weak, nonatomic) IBOutlet UILabel *lblFileName;
@property (weak, nonatomic) IBOutlet UILabel *lblFileSize;

- (void) setFileModel:(FileListModel *) model;
@end

NS_ASSUME_NONNULL_END
