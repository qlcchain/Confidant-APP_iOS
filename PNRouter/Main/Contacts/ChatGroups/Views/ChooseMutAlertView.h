//
//  ChooseMutAlertView.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/25.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseMutAlertView : UIView
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectV;
@property (weak, nonatomic) IBOutlet UITextField *messageTF;
@property (nonatomic ,strong) NSMutableArray *dataArray;
- (void) showAlertView;
- (void) hideAlertView;
+ (instancetype) loadChooseMutAlertView;
@end
