//
//  EmialListInfo.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/11.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "BBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EmailListInfo : BBaseModel
//1：qq企业邮箱
//2：qq邮箱
//3：163邮箱
//4：gmail邮箱
@property (nonatomic , assign) int Type;
@property (nonatomic , assign) int uid;
@property (nonatomic , strong) NSString *messageid;
@property (nonatomic , assign) int attachCount;
@property (nonatomic , strong) NSDate *revDate;
//1.收件箱
//2.发件箱
//3.草稿箱
//4.垃圾箱
@property (nonatomic , assign) int Label;
@property (nonatomic , assign) int Read;
@property (nonatomic ,strong) NSString *From;
@property (nonatomic ,strong) NSString *To;
@property (nonatomic ,strong) NSString *Subject;
@property (nonatomic ,strong) NSString *fromName;
@property (nonatomic ,strong) NSString *toName;
@property (nonatomic ,strong) NSString *content;
@property (nonatomic ,strong) NSString *htmlContent;
@property (nonatomic ,strong) NSString *Userkey;
@property (nonatomic ,strong) NSString *AttachInfo;
@property (nonatomic ,strong) NSString *EmailPath;

@property (nonatomic ,strong) NSString *floderName;
@property (nonatomic ,strong) NSString *floderPath;
// 附件
@property (nonatomic ,strong) NSMutableArray *attchArray;
// 收件人
@property (nonatomic ,strong) NSMutableArray *toUserArray;
// 抄送人
@property (nonatomic ,strong) NSMutableArray *ccUserArray;
// 密送人
@property (nonatomic ,strong) NSMutableArray *bccUserArray;

@end

NS_ASSUME_NONNULL_END
