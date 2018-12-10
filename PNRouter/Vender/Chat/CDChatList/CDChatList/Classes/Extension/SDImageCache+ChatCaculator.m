//
//  SDImageCache+ChatCaculator.m
//  CDChatList
//
//  Created by chdo on 2018/7/12.
//

#import "SDImageCache+ChatCaculator.h"

@implementation SDImageCache (ChatCaculator)

- (void)cd_storeImageData:(NSData *)imageData
                   forKey:(NSString *)key
                   toDisk:(BOOL)toDisk
               completion:(void(^)(void))completionBlock{
    
    if (!imageData) {
        if (completionBlock) {
            completionBlock();
        }
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wundeclared-selector"
    id memCache = [self performSelector:@selector(memCache) withObject:nil];
    
    if (self.config.shouldCacheImagesInMemory) {
        [memCache setObject:imageData forKey:key];
    }
    
//    dispatch_queue_t ioQueue = [self performSelector:@selector(ioQueue) withObject:nil];
#pragma clang diagnostic pop
    
    if (toDisk) {
//        dispatch_async(ioQueue, ^{
            @autoreleasepool {
                [self storeImageDataToDisk:imageData forKey:key];
            }
            
            if (completionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock();
                });
            }
//        });
    } else {
        if (completionBlock) {
            completionBlock();
        }
    }
}
@end
