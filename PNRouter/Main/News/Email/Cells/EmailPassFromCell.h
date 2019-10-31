//
//  EmailPassFromCell.h
//  MyConfidant
//
//  Created by 旷自辉 on 2019/10/29.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^ClickEncodeBlock)(void);

static NSString *EmailPassFromCellResu = @"EmailPassFromCell";
#define EmailPassFromCellHeight 210

@interface EmailPassFromCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblFrom;
@property (weak, nonatomic) IBOutlet UIButton *encodeBtn;

@property (nonatomic, copy) ClickEncodeBlock clickEncodeB;


@end

NS_ASSUME_NONNULL_END
