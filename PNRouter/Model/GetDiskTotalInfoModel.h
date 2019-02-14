//
//  GetDiskTotalInfoModel.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/2/14.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "BBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GetDiskTotalInfo : BBaseModel

@property (nonatomic, strong) NSNumber *Slot;
@property (nonatomic, strong) NSNumber *Status;
@property (nonatomic, strong) NSNumber *PowerOn;
@property (nonatomic, strong) NSNumber *Temperature;
@property (nonatomic, strong) NSString *Capacity;
@property (nonatomic, strong) NSString *Device;
@property (nonatomic, strong) NSString *Serial;

@end

@interface GetDiskTotalInfoModel : BBaseModel

@property (nonatomic, strong) NSNumber *Mode;
@property (nonatomic, strong) NSNumber *Count;
@property (nonatomic, strong) NSString *UsedCapacity;
@property (nonatomic, strong) NSString *TotalCapacity;
@property (nonatomic, strong) NSArray *Info;

@end

NS_ASSUME_NONNULL_END
