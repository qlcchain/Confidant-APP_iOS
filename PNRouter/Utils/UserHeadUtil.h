//
//  UserHeadUtil.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/3/8.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserHeadUtil : NSObject
+ (instancetype) getUserHeadUtilShare;
- (void) downUserHeadWithDic:(NSDictionary *) parames;
- (void) sendUpdateAvatarWithFid:(NSString *) fid md5:(NSString *) md5 showHud:(BOOL) isShow;
@end

NS_ASSUME_NONNULL_END
