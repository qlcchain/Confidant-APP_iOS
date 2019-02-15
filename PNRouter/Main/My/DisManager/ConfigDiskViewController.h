//
//  ConfigDiskViewController.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/28.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConfigDiskShowModel : NSObject

@property (nonatomic) BOOL isSelect;
@property (nonatomic) BOOL showArrow;
@property (nonatomic) BOOL showCell;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detail;
@property (nullable, nonatomic, strong) NSArray *cellArr;

@end

@interface ConfigDiskViewController : PNBaseViewController

@property (nonatomic, strong) NSNumber *currentMode;

@end

NS_ASSUME_NONNULL_END
