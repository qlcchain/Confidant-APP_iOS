//
//  DiskDetailCell.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/28.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *DiskDetailCellReuse = @"DiskDetailCell";
#define DiskDetailCell_Height 40

@interface DiskDetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleKeyLab;
@property (weak, nonatomic) IBOutlet UILabel *titleValLab;


- (void)configCellWithKey:(NSString *)key val:(NSString *)val;

@end

NS_ASSUME_NONNULL_END
