//
//  UploadFilesViewController.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"
#import "PNDocumentPickerViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface UploadFilesShowModel : NSObject

@property (nonatomic) BOOL isSelect;
@property (nonatomic) BOOL showArrow;
@property (nonatomic) BOOL showCell;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detail;
@property (nullable, nonatomic, strong) NSMutableArray *cellArr;

@end

@interface UploadFilesViewController : PNBaseViewController

@property (nonatomic, strong) NSArray *urlArr;
@property (nonatomic, strong) NSString *fileInfo;
@property (nonatomic, assign) BOOL isDoc;
@property (nonatomic) DocumentPickerType documentType;

@end

NS_ASSUME_NONNULL_END
