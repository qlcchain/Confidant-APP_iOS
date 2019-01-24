//
//  PNDocumentPickerViewController.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/24.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    DocumentPickerTypePhoto,
    DocumentPickerTypeVideo,
    DocumentPickerTypeDocument,
    DocumentPickerTypeOther,
} DocumentPickerType;

@interface PNDocumentPickerViewController : UIDocumentPickerViewController

@end

NS_ASSUME_NONNULL_END
