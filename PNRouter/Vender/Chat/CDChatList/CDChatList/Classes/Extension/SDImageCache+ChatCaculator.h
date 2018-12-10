//
//  SDImageCache+ChatCaculator.h
//  CDChatList
//
//  Created by chdo on 2018/7/12.
//


#import "SDImageCache.h"

@interface SDImageCache (ChatCaculator)
- (void)cd_storeImageData:(NSData *)imageData
                   forKey:(NSString *)key
                   toDisk:(BOOL)toDisk
               completion:(void(^)(void))completionBlock;
@end
