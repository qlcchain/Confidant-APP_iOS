//
//  EnPhotoCell.m
//  MyConfidant
//
//  Created by 旷自辉 on 2019/11/21.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "EnPhotoCell.h"
#import "PNFloderModel.h"

@implementation EnPhotoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void) setFloderM:(PNFloderModel *) floderM
{
    self.floderModel = floderM;
    _lblName.text = floderM.PathName;
    _lblNumber.text = [NSString stringWithFormat:@"%ld",floderM.FilesNum];
    
    NSString *sql = [NSString stringWithFormat:@"select count(%@) from %@ where %@=%@",bg_sqlKey(@"fId"),EN_FILE_TABNAME,bg_sqlKey(@"PathId"),bg_sqlValue(@(floderM.fId))];
    NSArray *results = bg_executeSql(sql, EN_FILE_TABNAME,nil);
    if (results && results.count > 0) {
        NSDictionary *countDic = results[0];
       _lblNumber.text = [NSString stringWithFormat:@"%d",[countDic[@"count(BG_fId)"] intValue]];
    } else {
        _lblNumber.text = 0;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
