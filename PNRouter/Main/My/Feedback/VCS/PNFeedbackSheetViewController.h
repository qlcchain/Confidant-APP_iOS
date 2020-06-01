//
//  PNFeedbackSheetViewController.h
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/20.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PNFeedbackSheetViewController : PNBaseViewController
- (instancetype) initWithSheetType:(NSInteger) sheetType dataArray:(NSMutableArray *) array selectStr:(NSString *) selStr;
@end

NS_ASSUME_NONNULL_END
