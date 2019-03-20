//
//  GroupMembersModel.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/19.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "GroupMembersModel.h"

@implementation GroupMembersModel

- (NSString *)showName {
    if (!_Remarks && _Remarks.length > 0) {
        return _Remarks;
    }
    return _Nickname;
}

@end
