//
//  EmojModel.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/5/30.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "BBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EmojModel : BBaseModel
@property (nonatomic, strong) NSString *emjName;
@property (nonatomic, assign) BOOL isDel;
@end

NS_ASSUME_NONNULL_END
