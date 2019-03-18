//
//  GroupMemberView.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/18.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GroupMemberView : UIView

@property (weak, nonatomic) IBOutlet UIButton *head1Btn;
@property (weak, nonatomic) IBOutlet UIButton *head2Btn;
@property (weak, nonatomic) IBOutlet UIButton *head3Btn;
@property (weak, nonatomic) IBOutlet UIButton *head4Btn;
@property (weak, nonatomic) IBOutlet UIButton *head5Btn;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *delBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contarintV3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contraintV4;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contraintV5;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contranitWith3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contraintWidth4;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contarintWidth5;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contraintWidthSub;

+ (instancetype)getInstance;
- (void) updateConstraintWithPersonCount:(NSArray *) persons;

@end

NS_ASSUME_NONNULL_END
