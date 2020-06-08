//
//  PNNewsCell.h
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/14.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

static NSString *PNNewsCellResue = @"PNNewsCell";
#define PNNewsCellHeight 136
#define PNNewsHeight 104

typedef void(^ClickDescBlock)(NSInteger row);

@interface PNNewsCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblSort;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentH;
@property (weak, nonatomic) IBOutlet UIImageView *imgEmail;
@property (weak, nonatomic) IBOutlet UILabel *lblDesc;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descH;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, copy) ClickDescBlock descBlock;
@end

NS_ASSUME_NONNULL_END
