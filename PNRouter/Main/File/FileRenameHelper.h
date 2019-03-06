//
//  FileRenameHelper.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/6.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FileListModel;

@interface FileRenameHelper : NSObject

+ (void)showRenameViewWithModel:(FileListModel *)model vc:(PNBaseViewController *)vc;

@end

NS_ASSUME_NONNULL_END
