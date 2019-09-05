//
//  EmailNodeModel.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/8/5.
//  Copyright © 2019 旷自辉. All rights reserved.
//


NS_ASSUME_NONNULL_BEGIN

@interface EmailNodeModel : BBaseModel
    
// 自己公钥加密的key
@property (nonatomic ,strong) NSString *dsKey;
// 标志
@property (nonatomic ,assign) NSInteger flags;
// 附件数量
@property (nonatomic ,assign) NSInteger attchCount;
// 标题
@property (nonatomic ,strong) NSString *subTitle;
// 正文 截取前面 50个字符
@property (nonatomic ,strong) NSString *content;
// 日期 秒时间搓
@property (nonatomic ,assign) NSInteger revDate;
// 发送人名字
@property (nonatomic ,strong) NSString *fromName;
// 发送人邮箱
@property (nonatomic ,strong) NSString *fromEmailBox;
// 收件人 名字 地址 json
@property (nonatomic ,strong) NSString *toUserJosn;
// 抄送人 名字 地址 json
@property (nonatomic ,strong) NSString *ccUserJosn;
// 密送人 名字 地址 json
@property (nonatomic ,strong) NSString *bccUserJosn;


@end

NS_ASSUME_NONNULL_END
