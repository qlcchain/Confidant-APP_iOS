//
//  FileDetailCell.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/11.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *FileDetailCellResue = @"FileDetailCell";
#define FileDetailCellHeight 47

@interface FileDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblContent;

@end
