//
//  DetailInformationCell.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *DetailInformationCellReuse = @"DetailInformationCell";
#define DetailInformationCellHeight 56

@interface DetailInformationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDesc;

@end

NS_ASSUME_NONNULL_END
