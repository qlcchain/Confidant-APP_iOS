//
//  EmialListInfo.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/11.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "EmailListInfo.h"

@implementation EmailListInfo
/**
 设置不需要存储的属性, 在模型.m文件中实现该函数.
 */
+(NSArray *)bg_ignoreKeys{
    return @[@"attchArray",@"toUserArray",@"ccUserArray",@"bccUserArray",@"fetchContentOp",@"deKey",@"isFetch",@"currentRow"];
}
@end
