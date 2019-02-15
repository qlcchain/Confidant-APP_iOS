//
//  GetDiskDetailInfoModel.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/2/15.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "BBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GetDiskDetailInfoModel : BBaseModel

@property (nonatomic, strong) NSNumber *Slot;
@property (nonatomic, strong) NSNumber *Status;
@property (nonatomic, strong) NSString *Name;
@property (nonatomic, strong) NSString *Device;
@property (nonatomic, strong) NSString *Serial;
@property (nonatomic, strong) NSString *Firmware;
@property (nonatomic, strong) NSString *FormFactor;
@property (nonatomic, strong) NSString *LUWWNDeviceId;
@property (nonatomic, strong) NSString *Capacity;
@property (nonatomic, strong) NSString *SectorSizes;
@property (nonatomic, strong) NSString *RotationRate;
@property (nonatomic, strong) NSString *ATAVersion;
@property (nonatomic, strong) NSString *SATAVersion;
@property (nonatomic, strong) NSString *SMARTsupport;
@property (nonatomic, strong) NSString *ModelFamily;

@end

NS_ASSUME_NONNULL_END
