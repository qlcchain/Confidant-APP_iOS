//
//  LogOutCell.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/27.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *LogOutCellReuse = @"LogOutCell";
#define LogOutCell_Height 66

typedef void(^LogOutBlock)(void);

@interface LogOutCell : UITableViewCell

@property (nonatomic, copy) LogOutBlock logOutB;

@end

NS_ASSUME_NONNULL_END
