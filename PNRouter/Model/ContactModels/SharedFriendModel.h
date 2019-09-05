//
//  SharedFriendModel.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/25.
//  Copyright © 2019 旷自辉. All rights reserved.
//


NS_ASSUME_NONNULL_BEGIN

@interface SharedFriendModel : BBaseModel

@property (nonatomic, copy) NSString *Name;
@property (nonatomic, copy) NSString *Remarks;
@property (nonatomic, copy) NSString *Id;
@property (nonatomic, copy) NSString *UserKey;
@property (nonatomic, copy) NSNumber *Status; // 0：离线  1：在线  2：隐身  3：忙碌


@end

NS_ASSUME_NONNULL_END
