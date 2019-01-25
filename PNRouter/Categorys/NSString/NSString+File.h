//
//  NSString+File.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/25.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (File)

+ (NSInteger)fileSizeAtPath:(NSString*)filePath;

@end

NS_ASSUME_NONNULL_END
