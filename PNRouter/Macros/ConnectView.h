//
//  ConnectView.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/12/6.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConnectView : UIView

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activeView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIView *backView;

+ (instancetype) loadConnectView;

- (void) showConnectView;
- (void) hiddenConnectView;
@end

NS_ASSUME_NONNULL_END
