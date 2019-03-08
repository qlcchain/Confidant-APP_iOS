//
//  FileCell.m
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/11.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "FileCell.h"
#import "FileListModel.h"
#import "PNRouter-Swift.h"
#import "NSDate+Category.h"
#import "NSString+Base64.h"
#import "SystemUtil.h"
#import "UserConfig.h"
#import "NSString+Base64.h"
#import "PNDefaultHeaderView.h"
#import "EntryModel.h"

@interface FileCell ()

@end

@implementation FileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _timeLab.text = nil;
    _nameLab.text = nil;
    _fileNameLab.text = nil;
//    _spellLab.text = nil;
    _operationLab.text = nil;
    _sizeLab.text = nil;
}

- (void)configCellWithModel:(FileListModel *)model {
    _timeLab.text = [NSDate formattedUploadFileTimeFromTimeInterval:[model.Timestamp  intValue]];
    NSString *lastPath = model.FileName.lastPathComponent;
    _fileNameLab.text = [Base58Util Base58DecodeWithCodeName:lastPath];
    _sizeLab.text = [SystemUtil transformedValue:[model.FileSize floatValue]];
    NSString *operationImgStr = @"";
    NSString *nameStr = @"";
    NSString *operationStr = @"";
    if (model.FileFrom == 1) { // 发出
        operationImgStr = @"icon_file_sent_black";
        nameStr = [model.Sender base64DecodedString];
        operationStr = @"File Sent";
    } else if (model.FileFrom == 2) { // 接受
        operationImgStr = @"icon_file_black";
        nameStr = [model.Sender base64DecodedString];
        operationStr = @"File Received";
    } else if (model.FileFrom == 3) { // 上传
        operationImgStr = @"icon_upload_small_gray";
        nameStr = [model.Sender base64DecodedString];
        operationStr = @"My File";
    } else {
        operationStr = @"File Sent";
        operationImgStr = @"icon_file_sent_black";
        nameStr = [UserConfig getShareObject].userName;
    }
    _operationIcon.image = [UIImage imageNamed:operationImgStr];
    _nameLab.text = nameStr;
    NSString *userKey = model.UserKey;
    NSString *key = [EntryModel getShareObject].signPublicKey;
    UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:nameStr] fontSize:18];
    _headerImgV.image = defaultImg;
//    _spellLab.text = [StringUtil getUserNameFirstWithName:nameStr];
    _operationLab.text = operationStr;
    
    NSString *fileTypeImgName = @"";
    switch ([model.FileType intValue]) {
        case 1:
            fileTypeImgName = @"icon_picture_small_gray";
            break;
        case 2:
            fileTypeImgName = @"icon_video_small_gray";
            break;
        case 4:
            fileTypeImgName = @"icon_video_small_gray";
            break;
        case 5:
            fileTypeImgName = @"icon_document_small_gray";
            break;
            
        default:
            fileTypeImgName = @"icon_other_small_gray";
            break;
    }
    _icon.image = [UIImage imageNamed:fileTypeImgName];
}

- (IBAction)moreAction:(id)sender {
    if (_fileMoreB) {
        _fileMoreB();
    }
}

- (IBAction)forwardAction:(id)sender {
    if (_fileForwardB) {
        _fileForwardB();
    }
}

- (IBAction)downloadAction:(id)sender {
    if (_fileDownloadB) {
        _fileDownloadB();
    }
}

@end
