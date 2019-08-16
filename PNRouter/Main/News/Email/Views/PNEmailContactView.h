//
//  PNEmailContactView.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/8/15.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EmailContactModel;

NS_ASSUME_NONNULL_BEGIN

typedef void(^ClickContactBlock)(EmailContactModel *contactModel);

@interface PNEmailContactView : UIView
@property (weak, nonatomic) IBOutlet UITableView *mainTabView;
@property (nonatomic, copy) ClickContactBlock contactBlock;
- (void) setLoadDataArray:(NSMutableArray *) arr;
+ (instancetype) loadPNEmailContactView;
@end

NS_ASSUME_NONNULL_END
