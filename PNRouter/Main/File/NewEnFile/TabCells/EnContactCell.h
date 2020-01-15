//
//  EnContactCell.h
//  MyConfidant
//
//  Created by 旷自辉 on 2020/1/8.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *EnContactCellResue = @"EnContactCell";

@interface EnContactCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblLocalCount;
@property (weak, nonatomic) IBOutlet UILabel *lblNodeCount;

@end

NS_ASSUME_NONNULL_END
