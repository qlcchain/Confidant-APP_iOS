//
//  MsgPicViewController.h
//  CDChatList_Example
//
//  Created by chdo on 2018/4/29.
//  Copyright © 2018年 chdo002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDChatList.h"

@interface MsgPicViewController : UIViewController
@property(nonatomic, strong) UIImage *img;
@property(nonatomic, assign) CGRect imgRectIntTableView;
@property(nonatomic, copy) CDChatMessageArray msgs;
@property(nonatomic, copy) NSString *msgId;

@property(nonatomic, strong) UIImageView *imgView;

+(void)addToRootViewController:(UIImage *)img
                       ofMsgId:(NSString *)msgId
                            in:(CGRect)imgRectIntTableView
                          from: (CDChatMessageArray) msgs;
@end
