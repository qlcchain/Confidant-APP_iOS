//
//  YBIBCopywriter.m
//  YBImageBrowserDemo
//
//  Created by 杨波 on 2018/9/13.
//  Copyright © 2018年 杨波. All rights reserved.
//

#import "YBIBCopywriter.h"

@implementation YBIBCopywriter

#pragma mark - life cycle

+ (instancetype)shareCopywriter {
    static YBIBCopywriter *copywriter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        copywriter = [YBIBCopywriter new];
    });
    return copywriter;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        YBIBCopywriterType type = YBIBCopywriterTypeSimplifiedChinese;
        NSArray *appleLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
        if (appleLanguages && appleLanguages.count > 0) {
            NSString *languages = appleLanguages[0];
            if (![languages isEqualToString:@"zh-Hans-CN"]) {
                type = YBIBCopywriterTypeEnglish;
            }
        }
        self.type = type;
            
        [self initCopy];
    }
    return self;
}

#pragma mark - private

- (void)initCopy {
    BOOL en = self.type == YBIBCopywriterTypeEnglish;
    
    self.videoIsInvalid = en ? @"Video is invalid" : @"Video is invalid";
    self.videoError = en ? @"Video error" : @"Video error";
    self.unableToSave = en ? @"Unable to save" : @"Unable to save";
    self.imageIsInvalid = en ? @"Image is invalid" : @"Image is invalid";
    self.downloadImageFailed = en ? @"Download failed" : @"Download failed";
    self.getPhotoAlbumAuthorizationFailed = en ? @"Failed to get album authorization" : @"Failed to get album authorization";
    self.saveToPhotoAlbumSuccess = en ? @"Save successful" : @"Save successful";
    self.saveToPhotoAlbumFailed = en ? @"Save failed" : @"Save failed";
    self.saveToPhotoAlbum = en ? @"Save" : @"Save";
    self.cancel = en ? @"Cancel" : @"Cancel";
}

#pragma mark - public

- (void)setType:(YBIBCopywriterType)type {
    _type = type;
    [self initCopy];
}


@end
