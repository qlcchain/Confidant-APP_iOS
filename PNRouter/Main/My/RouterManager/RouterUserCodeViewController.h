//
//  RouterUserCodeViewController.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/26.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"
#import "RouterUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RouterUserCodeViewController : PNBaseViewController
@property (weak, nonatomic) IBOutlet UILabel *lblNavTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblDesc;
@property (nonatomic , strong) RouterUserModel *routerUserModel;
@end

NS_ASSUME_NONNULL_END
