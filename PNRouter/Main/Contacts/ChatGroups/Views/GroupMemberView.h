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


+ (instancetype)getInstance;

@end

NS_ASSUME_NONNULL_END
