//
//  GoogleUserModel.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/10/14.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <LibsodiumSDK/LibsodiumSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface GoogleUserModel : BBaseModel
@property (nonatomic ,strong) NSString *userId;                  // For client-side use only!
@property (nonatomic ,strong) NSString *idToken; // Safe to send to the server
@property (nonatomic ,strong) NSString *fullName;
@property (nonatomic ,strong) NSString *givenName;
@property (nonatomic ,strong) NSString *familyName;
@property (nonatomic ,strong) NSString *email;

+ (void) addGoogleUserWithUser:(GoogleUserModel *) userModel;
+ (GoogleUserModel *) getCurrentUserModel:(NSString *) email;

@end

NS_ASSUME_NONNULL_END
