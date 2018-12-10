//
//  CTinputHelper.h
//  CDChatList
//
//  Created by chdo on 2017/12/12.
//

#import <Foundation/Foundation.h>
#import "CTInputConfiguration.h"

@interface CTinputHelper : NSObject

@property(nonatomic, strong, class, readonly) CTinputHelper *share;

#pragma mark 组件配置相关
@property(nonatomic, strong) CTInputConfiguration *config;

#pragma mark  表情相关

/**
 表情字典
 @return <NameString: UIImage>
 */
// 表情字典
@property(nonatomic, strong) NSDictionary<NSString*, UIImage *> *emojDic;
#pragma mark  资源图片
@property(nonatomic, strong) NSDictionary<NSString*, UIImage *> *imageDic;

#pragma mark 表情名数组
/**
 @[ @[@"[微笑]",@"[呵呵]"],   @[@"[:微笑:",@":呵呵:"] ]
 */
@property(nonatomic, copy) NSArray<NSArray<NSString *> *> *emojiNameArr; // 表情图片名组成的数组  可对应多个集合
@property(nonatomic, copy) NSArray<NSString *> *emojiNameArrTitles;


    
@end
