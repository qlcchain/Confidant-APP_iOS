//
//  EmailInfo.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/10.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EmailInfo : BBaseModel
@property (nonatomic , strong) NSString *User;
@property (nonatomic , strong) NSString *UserKey;
@property (nonatomic , strong) NSString *Conf;
@property (nonatomic , strong) NSString *Sign;
@property (nonatomic , strong) NSString *ContactsFile;
@property (nonatomic , strong) NSString *ContactsMd5;
@property (nonatomic , assign) int Type;

@end

NS_ASSUME_NONNULL_END
