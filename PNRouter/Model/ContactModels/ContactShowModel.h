//
//  ContactShowModel.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/2/21.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "BBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContactRouterModel : BBaseModel

@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString *RouteId;
@property (nonatomic, strong) NSString *RouteName;

@end

@interface ContactShowModel : BBaseModel

@property (nonatomic, strong) NSString *RouteName;
@property (nonatomic, strong) NSString *Index;
@property (nonatomic, strong) NSString *Name;
@property (nonatomic, strong) NSString *Remarks;
@property (nonatomic, strong) NSString *UserKey;
@property (nonatomic, strong) NSNumber *Status;
@property (nonatomic, strong) NSString *publicKey;
//@property (nonatomic, strong) NSString *remarks;
@property (nonatomic, strong) NSMutableArray *routerArr;

@property (nonatomic) BOOL showCell;
@property (nonatomic) BOOL showArrow;

@end

NS_ASSUME_NONNULL_END
