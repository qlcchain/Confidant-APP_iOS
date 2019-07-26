//
//  EmailDataBaseUtil.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EmailDataBaseUtil : NSObject

+ (void) insertDataWithUser:(NSString *) user userName:(NSString *) userName  userAddress:(NSString *) userAddress;
@end

NS_ASSUME_NONNULL_END
