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

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _head1Btn.layer.cornerRadius = _head1Btn.width/2.0;
    _head1Btn.layer.masksToBounds = YES;
    _head2Btn.layer.cornerRadius = _head2Btn.width/2.0;
    _head2Btn.layer.masksToBounds = YES;
    _head3Btn.layer.cornerRadius = _head3Btn.width/2.0;
    _head3Btn.layer.masksToBounds = YES;
    _head4Btn.layer.cornerRadius = _head4Btn.width/2.0;
    _head4Btn.layer.masksToBounds = YES;
    _head5Btn.layer.cornerRadius = _head5Btn.width/2.0;
    _head5Btn.layer.masksToBounds = YES;
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
    if (_addB) {
        _addB();
    }
}

- (IBAction)delAction:(id)sender {
    if (_delB) {
        _delB();
    }
}

- (void) updateConstraintWithPersonCount:(NSArray *) persons {
    CGFloat V_val0 = 0;
    CGFloat V_val10 = 10;
    CGFloat With_val0 = 0;
    CGFloat With_val32 = 32;
    if (persons.count <= 0) {
        _contarintV2.constant = V_val0;
        _contarintV3.constant = V_val0;
        _contraintV4.constant = V_val0;
        _contraintV5.constant = V_val0;
        
        _contraintWith1.constant = With_val0;
        _contraintWith2.constant = With_val0;
        _contranitWith3.constant = With_val0;
        _contarintWidth5.constant = With_val0;
        _contraintWidth4.constant = With_val0;
    } else {
        FriendModel *model1 = [persons objectAtIndex:0];
        NSString *userKey = model1.signPublicKey;
        UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:model1.username]];
        [_head1Btn setImage:defaultImg forState:UIControlStateNormal];
        
        _contraintWith1.constant = With_val32;
        if (persons.count <= 1) {
            _contarintV2.constant = V_val0;
            _contarintV3.constant = V_val0;
            _contraintV4.constant = V_val0;
            _contraintV5.constant = V_val0;
            
            _contraintWith2.constant = With_val0;
            _contranitWith3.constant = With_val0;
            _contarintWidth5.constant = With_val0;
            _contraintWidth4.constant = With_val0;
            
        } else {
            FriendModel *model2 = [persons objectAtIndex:1];
            NSString *userKey = model2.signPublicKey;
            UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:model2.username]];
            [_head2Btn setImage:defaultImg forState:UIControlStateNormal];
            
            _contarintV2.constant = V_val10;
            _contraintWith2.constant = With_val32;
            if (persons.count == 2) {
                _contarintV3.constant = V_val0;
                _contraintV4.constant = V_val0;
                _contraintV5.constant = V_val0;
                
                _contranitWith3.constant = With_val0;
                _contarintWidth5.constant = With_val0;
                _contraintWidth4.constant = With_val0;
            } else {
                FriendModel *model3 = [persons objectAtIndex:2];
                NSString *userKey = model3.signPublicKey;
                UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:model3.username]];
                [_head3Btn setImage:defaultImg forState:UIControlStateNormal];
                
                _contarintV3.constant = V_val10;
                _contranitWith3.constant = With_val32;
                if (persons.count <= 3) {
                    _contraintV4.constant = V_val0;
                    _contraintV5.constant = V_val0;
                    
                    _contraintWidth4.constant = With_val0;
                    _contarintWidth5.constant = With_val0;
                } else {
                    FriendModel *model4 = [persons objectAtIndex:3];
                    NSString *userKey = model4.signPublicKey;
                    UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:model4.username]];
                    [_head4Btn setImage:defaultImg forState:UIControlStateNormal];
                    
                    _contraintV4.constant = V_val10;
                    _contraintWidth4.constant = With_val32;
                    if (persons.count <= 4) {
                        _contraintV5.constant = V_val0;
                        _contarintWidth5.constant = With_val0;
                    } else {
                        FriendModel *model5 = [persons objectAtIndex:4];
                        NSString *userKey = model5.signPublicKey;
                        UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:model5.username]];
                        [_head5Btn setImage:defaultImg forState:UIControlStateNormal];
                        
                        _contraintV5.constant = V_val10;
                        _contarintWidth5.constant = With_val32;
                    }
                }
            }
        }
    }
}

@end
