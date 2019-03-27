//
//  LogOutCell.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/27.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "LogOutCell.h"

@implementation LogOutCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)logOutAction:(id)sender {
    if (_logOutB) {
        _logOutB();
    }
}

@end

