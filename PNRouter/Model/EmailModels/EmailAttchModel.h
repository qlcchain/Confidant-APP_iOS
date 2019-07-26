//
//  EmailAttchModel.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/18.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "BBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EmailAttchModel : BBaseModel

@property (nonatomic ,strong) NSString *attId;
@property (nonatomic ,strong) NSString *attName;
@property (nonatomic ,strong) NSData *attData;
@end

NS_ASSUME_NONNULL_END
