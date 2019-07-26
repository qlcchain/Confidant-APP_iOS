//
//  EmailAttchCell.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/15.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *EmailAttchCellResue = @"EmailAttchCell";

typedef void(^ClickAttchBlock)(NSInteger selItem);

@interface EmailAttchCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UICollectionView *collectionV;
@property (nonatomic ,strong) NSMutableArray *attchArray;
@property (nonatomic ,copy) ClickAttchBlock clickAttBlock;
- (void) setAttchs:(NSArray *) atts;
@end

NS_ASSUME_NONNULL_END
