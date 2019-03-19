//
//  ChooseContactShowModel.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/2/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "BBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ChooseContactRouterModel : BBaseModel

@property (nonatomic, strong) NSString *Id;
@property (nonatomic, strong) NSString *RouteId;
@property (nonatomic, strong) NSString *RouteName;

@property (nonatomic) BOOL showSelect;
@property (nonatomic) BOOL isSelect;

@end

@interface ChooseContactShowModel : BBaseModel

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
@property (nonatomic) BOOL showSelect;
@property (nonatomic) BOOL isSelect;
@property (nonatomic) BOOL userInterfaceOff;

@end

NS_ASSUME_NONNULL_END
