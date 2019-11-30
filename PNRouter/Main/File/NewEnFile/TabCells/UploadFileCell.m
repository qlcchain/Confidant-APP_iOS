//
//  UploadFileCell.m
//  MyConfidant
//
//  Created by 旷自辉 on 2019/11/21.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "UploadFileCell.h"
#import "PNFileModel.h"
#import "SystemUtil.h"

@implementation UploadFileCell
- (IBAction)clickOptionAction:(id)sender {
    if (_optionBlock) {
        _optionBlock();
    }
}
- (void) setFileM:(PNFileModel *) fileModel
{
    self.fileModel = fileModel;
    _lblName.text = fileModel.Fname;
    _lblDesc.text = [SystemUtil transformedValue:fileModel.Size];
    if (fileModel.Type == 1) {
        _typeImgView.image = [UIImage imageNamed:@"jpg"];
    } else if (fileModel.Type == 4) {
        _typeImgView.image = [UIImage imageNamed:@"mp4"];
    } else {
        NSString *fileType = [[fileModel.Fname componentsSeparatedByString:@"."] lastObject];
        UIImage *typeImg = [UIImage imageNamed:[fileType lowercaseString]];
        if (typeImg) {
            _typeImgView.image = typeImg;
        } else {
            _typeImgView.image = [UIImage imageNamed:@"other"];
        }
        
    }
    
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
