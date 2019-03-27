//
//  ChooseCircleCell.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/27.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RouterModel;

@interface ChooseCircleShowModel : NSObject

@property (nonatomic) BOOL showSelect;
@property (nonatomic) BOOL isSelect;
@property (nonatomic, strong) RouterModel *routerM;

@end

typedef void(^ChooseCircleSelectBlock)(NSInteger tableRow);

static NSString *ChooseCircleCellReuse = @"ChooseCircleCell";
#define ChooseCircleCell_Height 56

@interface ChooseCircleCell : UITableViewCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftContraintW;
@property (weak, nonatomic) IBOutlet UIImageView *selectImgView;
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UIImageView *connectIcon;

@property (nonatomic) NSInteger tableRow;
@property (nonatomic, copy) ChooseCircleSelectBlock selectB;

- (void)configCellWithModel:(ChooseCircleShowModel *)model;

@end

NS_ASSUME_NONNULL_END
