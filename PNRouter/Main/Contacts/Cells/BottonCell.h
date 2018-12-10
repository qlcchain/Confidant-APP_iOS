//
//  BottonCell.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/11.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *BottonCellResue = @"BottonCell";
#define BottonCellHeight 60

typedef void(^DeleteContactBlock)(void);
typedef void(^SendMessageBlock)(void);

@interface BottonCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *sendMessageBtn;
@property (weak, nonatomic) IBOutlet UIButton *delegateBtn;

@property (nonatomic, copy) DeleteContactBlock deleteContactB;
@property (nonatomic, copy) DeleteContactBlock sendMessageB;

@end
