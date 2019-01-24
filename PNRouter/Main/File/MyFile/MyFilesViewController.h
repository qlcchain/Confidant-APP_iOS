//
//  MyFilesViewController.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    FilesTypeMy,
    FilesTypeShare,
    FilesTypeReceived,
} FilesType;

@interface MyFilesViewController : PNBaseViewController

@property (nonatomic) FilesType filesType;

@end

NS_ASSUME_NONNULL_END
