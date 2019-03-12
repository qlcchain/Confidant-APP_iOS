//
//  FileConfig.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/3/12.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface FileConfig : NSObject

singleton_interface(FileConfig)
// 最大上传大小
@property (nonatomic , assign) int uploadFileMaxSize;

@end

NS_ASSUME_NONNULL_END
