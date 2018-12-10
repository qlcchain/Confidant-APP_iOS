//
//  VPNUtil.h
//  Qlink
//
//  Created by 旷自辉 on 2018/4/20.
//  Copyright © 2018年 pan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VPNFileUtil : NSObject

+ (void) saveVPNDataToLibrayPath:(NSData *) data withFileName:(NSString *) fileName;
// 根据文件名得到路径
+ (NSString *) getVPNPathWithFileName:(NSString *) fileName;
+ (void) removeVPNFile;
+ (NSString *)getTempPath;


@end
