//
//  UserConfig.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/12/25.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserConfig : NSObject

@property (nonatomic ,strong) NSString *userId;
@property (nonatomic ,strong) NSString *hashId;
@property (nonatomic ,strong) NSString *usersn;
@property (nonatomic ,strong) NSString *userName;
@property (nonatomic ,strong) NSString *passWord;
@property (nonatomic, assign) NSInteger dataFileVersion;
@property (nonatomic, copy) NSString *dataFilePay;

+ (instancetype) getShareObject;
@end

NS_ASSUME_NONNULL_END
