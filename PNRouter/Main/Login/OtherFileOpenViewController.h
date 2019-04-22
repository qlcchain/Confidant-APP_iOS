//
//  OtherFileOpenViewController.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/4/9.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface OtherFileOpenViewController : PNBaseViewController

@property (nonatomic ,strong) PNBaseViewController *backVC;

- (id) initWithFileUrl:(NSURL *) fileUrl;
@end

NS_ASSUME_NONNULL_END
