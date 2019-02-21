//
//  QRCodeViewController.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/10.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"

@interface PersonCodeViewController : PNBaseViewController
@property (weak, nonatomic) IBOutlet UILabel *lblNavTitle;
- (instancetype) initWithUserId:(NSString *) userId userNaem:(NSString *) userNaem signPK:(NSString *) signPK;
@end
