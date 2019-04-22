//
//  FriendDetailViewController.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/11.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"

@class FriendModel;
//@class ContactShowModel;

@interface FriendDetailViewController : PNBaseViewController

@property (weak, nonatomic) IBOutlet UILabel *lblNavTitle;
@property (nonatomic, strong) FriendModel *friendModel;
@property (nonatomic , assign) BOOL isBack;
@property (nonatomic , assign) BOOL isGroup;
//@property (nonatomic, strong) ContactShowModel *contactShowM;

@end
