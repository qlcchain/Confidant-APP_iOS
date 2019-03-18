//
//  GroupMemberView.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/18.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "GroupMemberView.h"
#import "FriendModel.h"
#import "PNDefaultHeaderView.h"

@implementation GroupMemberView

+ (instancetype)getInstance {
    GroupMemberView *view = [[[NSBundle mainBundle] loadNibNamed:@"GroupMemberView" owner:self options:nil] lastObject];
    return view;
}

- (IBAction)head1Action:(id)sender {
    
}

- (IBAction)head2Action:(id)sender {
    
}

- (IBAction)head3Action:(id)sender {
    
}

- (IBAction)head4Action:(id)sender {
    
}

- (IBAction)head5Action:(id)sender {
    
}

- (IBAction)addAction:(id)sender {
    
}

- (IBAction)delAction:(id)sender {
    
}

- (void) updateConstraintWithPersonCount:(NSArray *) persons
{
    
    FriendModel *model1 = [persons objectAtIndex:0];
    NSString *userKey = model1.signPublicKey;
    UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:model1.username]];
    _head1Btn.layer.cornerRadius = _head1Btn.width/2.0;
    _head1Btn.layer.masksToBounds = YES;
    [_head1Btn setImage:defaultImg forState:UIControlStateNormal];
    
    FriendModel *model2 = [persons objectAtIndex:1];
    userKey = model2.signPublicKey;
    defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:model2.username]];
    _head2Btn.layer.cornerRadius = _head2Btn.width/2.0;
    _head2Btn.layer.masksToBounds = YES;
    [_head2Btn setImage:defaultImg forState:UIControlStateNormal];
    
    if (persons.count == 2) {
        _contarintV3.constant = 0;
        _contraintV4.constant = 0;
        _contraintV5.constant = 0;
        
        _contranitWith3.constant = 0;
        _contarintWidth5.constant = 0;
        _contraintWidth4.constant = 0;
        _contraintWidthSub.constant = 0;
        
    } else if (persons.count == 3) {
        _contraintV4.constant = 0;
        _contraintV5.constant = 0;
        
        _contarintWidth5.constant = 0;
        _contraintWidth4.constant = 0;
        
        FriendModel *model3 = [persons objectAtIndex:2];
        userKey = model3.signPublicKey;
        defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:model3.username]];
        _head3Btn.layer.cornerRadius = _head3Btn.width/2.0;
        _head3Btn.layer.masksToBounds = YES;
        [_head3Btn setImage:defaultImg forState:UIControlStateNormal];
        
    } else if (persons.count == 4) {
        
        FriendModel *model4 = [persons objectAtIndex:3];
        userKey = model4.signPublicKey;
        defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:model4.username]];
        _head4Btn.layer.cornerRadius = _head4Btn.width/2.0;
        _head4Btn.layer.masksToBounds = YES;
        [_head4Btn setImage:defaultImg forState:UIControlStateNormal];
        
        _contraintV5.constant = 0;
        _contarintWidth5.constant = 0;
    } else {
        
        FriendModel *model5 = [persons objectAtIndex:4];
        userKey = model5.signPublicKey;
        defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:model5.username]];
        _head5Btn.layer.cornerRadius = _head4Btn.width/2.0;
        _head5Btn.layer.masksToBounds = YES;
        [_head5Btn setImage:defaultImg forState:UIControlStateNormal];
    }
}

@end
