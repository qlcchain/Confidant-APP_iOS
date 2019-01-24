//
//  FileCell.h
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/11.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

//#import <SWTableViewCell/SWTableViewCell.h>
#import <UIKit/UIKit.h>

static NSString *FileCellReuse = @"FileCell";
#define FileCellHeight 64

//@interface FileCell : SWTableViewCell
@interface FileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *icon;


@end
