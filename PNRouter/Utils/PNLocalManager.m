//
//  PNLocalManager.m
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/12.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "PNLocalManager.h"

@implementation PNLocalManager

- (void)startLocation
{
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    //这里设置为最高精度定位
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    //设备移动10米通知代理器更新位置
    _locationManager.distanceFilter = 1000.0f;
    [_locationManager startUpdatingLocation];
    
    
    
}
//定位代理经纬度回调
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //此处locations存储了持续更新的位置坐标值，取最后一个值为最新位置，如果不想让其持续更新位置，则在此方法中获取到一个值之后让locationManager stopUpdatingLocation
    
    CLLocation *currentLocation = [locations lastObject];
    NSLog(@"%@",[NSString stringWithFormat:@"纬度:%3.5f\n经度:%3.5f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude]);
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
    
    {
        for (CLPlacemark * placemark in placemarks) {
            
            NSString *city = placemark.locality;
            if (!city) {
                //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                city = placemark.administrativeArea;
            }
            NSLog(@"address = %@\n",placemark.name);
            NSDictionary *dictionary = [placemark addressDictionary];
            //  Country(国家)  State(省) locality（市） SubLocality(区)
            NSLog(@"国家名称 =%@,国家代码 =%@",placemark.country,placemark.ISOcountryCode);
        }
        if (error == nil && [placemarks count] == 0)
        {
            NSLog(@"No results were returned.");
        }
        else if (error != nil)
        {
            NSLog(@"An error occurred = %@", error);
        }
    }];
    
    //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
    
    [manager stopUpdatingLocation];
}
@end
