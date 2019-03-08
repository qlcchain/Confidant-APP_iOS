//
//  MyHeadView.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/10.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyHeadView : UIView
@property (weak, nonatomic) IBOutlet UIButton *HeanBtn;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (nonatomic , assign) BOOL isMyHead;
+ (instancetype) loadMyHeadView;
- (void) setUserNameFirstWithName:(NSString *)userName userKey:(NSString *)userKey;
@end
