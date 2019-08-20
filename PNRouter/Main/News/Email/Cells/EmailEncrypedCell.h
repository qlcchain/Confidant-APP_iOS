//
//  EmailEncrypedCell.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/8/19.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


static NSString * _Nullable EmailEncrypedCellResue = @"EmailEncrypedCell";
#define EmailEncrypedCellHeight 56

@interface EmailEncrypedCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UIImageView *selImgView;

@end

NS_ASSUME_NONNULL_END
