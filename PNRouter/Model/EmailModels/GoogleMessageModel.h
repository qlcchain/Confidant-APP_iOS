//
//  GoogleMessageModel.h
//  MyConfidant
//
//  Created by 旷自辉 on 2019/10/17.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GoogleMessageModel : BBaseModel

@property (nonatomic ,strong) NSString *messageId;                  // For client-side use only!
@property (nonatomic ,assign) NSInteger internalDate; // Safe to send to the server
@property (nonatomic ,strong) NSArray *labelIds;
@property (nonatomic ,strong) NSString *snippet;
@property (nonatomic ,strong) NSDictionary *payload;
@property (nonatomic ,strong) NSString *threadId;
@property (nonatomic ,assign) BOOL isRead;
@property (nonatomic ,assign) BOOL isStarred;
@property (nonatomic ,strong) NSString *Subject;
@property (nonatomic ,strong) NSString *From;
@property (nonatomic ,strong) NSString *FromName;
@property (nonatomic ,strong) NSString *To;
@property (nonatomic ,strong) NSString *Cc;
@property (nonatomic ,strong) NSString *Bcc;
@property (nonatomic ,strong) NSString *htmlContent;
@property (nonatomic ,strong) NSString *friendId;
@property (nonatomic ,strong) NSString *deKey;
@property (nonatomic , assign) int attachCount;
@property (nonatomic, strong) NSMutableArray *attArray;
@property (nonatomic, strong) NSMutableArray *cidArray;

// 当前cellRow
@property (nonatomic ,assign) NSInteger currentRow;
@end

NS_ASSUME_NONNULL_END
