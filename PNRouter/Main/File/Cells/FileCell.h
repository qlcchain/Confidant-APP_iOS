//
//  FileCell.h
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/11.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

//#import <SWTableViewCell/SWTableViewCell.h>
#import <UIKit/UIKit.h>

@class FileListModel;

static NSString *FileCellReuse = @"FileCell";
#define FileCellHeight 153

typedef void(^FileMoreBlock)(void);
typedef void(^FileForwardBlock)(void);
typedef void(^FileDownloadBlock)(void);

//@interface FileCell : SWTableViewCell
@interface FileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *timeLab;
@property (weak, nonatomic) IBOutlet UIImageView *operationIcon;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLab;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
@property (nonatomic, copy) FileMoreBlock fileMoreB;
@property (weak, nonatomic) IBOutlet UIButton *forwardBtn;
@property (nonatomic, copy) FileForwardBlock fileForwardB;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (nonatomic, copy) FileDownloadBlock fileDownloadB;

@property (weak, nonatomic) IBOutlet UIImageView *headerImgV;
//@property (weak, nonatomic) IBOutlet UILabel *spellLab;
@property (weak, nonatomic) IBOutlet UILabel *operationLab;
@property (weak, nonatomic) IBOutlet UILabel *sizeLab;

- (void)configCellWithModel:(FileListModel *)model;

@end
