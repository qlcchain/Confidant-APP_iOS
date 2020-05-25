//
//  PNLocalManager.h
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/12.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PNLocalManager : NSObject<CLLocationManagerDelegate>
//位置管理
@property (strong, nonatomic) CLLocationManager *locationManager;

- (void)startLocation;
@end

NS_ASSUME_NONNULL_END
