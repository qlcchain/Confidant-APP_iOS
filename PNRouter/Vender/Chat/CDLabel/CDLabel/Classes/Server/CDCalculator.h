//
//  CDCalculator.h
//  CDLabel
//
//  Created by chdo on 2018/6/28.
//

#import <Foundation/Foundation.h>
#import "CDLabel.h"
#import "CTData.h"

@interface CDCalculator : NSObject

@property(class, nonatomic, strong, readonly) CDCalculator *share;

@property(nonatomic, weak) CDLabel *label;

// 文本计算渲染完成
@property(nonatomic,strong)void(^calComplete)(CTData *data);

-(void)calcuate:(NSString *)text and:(CGSize)containSize and:(CTDataConfig)config;

-(void)calcuate:(NSAttributedString *)text and:(CGSize)containSize;
@end
