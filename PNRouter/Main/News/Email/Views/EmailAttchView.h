//
//  EmailAttchView.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/29.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ClickAttchBlock)(NSInteger selItem);

NS_ASSUME_NONNULL_BEGIN

@interface EmailAttchView : UIView
@property (weak, nonatomic) IBOutlet UICollectionView *collectionV;
@property (nonatomic ,strong) NSMutableArray *attchArray;
@property (nonatomic, strong) NSString *deKey;
@property (nonatomic ,copy) ClickAttchBlock clickAttBlock;
- (void) setAttchs:(NSArray *) atts deKey:(NSString *) deKey;
@end

NS_ASSUME_NONNULL_END
