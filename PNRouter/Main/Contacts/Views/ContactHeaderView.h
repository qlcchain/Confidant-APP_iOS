//
//  UploadFilesHeaderView.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ContactShowModel;

static NSString *ContactHeaderViewReuse = @"ContactHeaderView";
#define ContactHeaderViewHeight 56

//typedef void(^ContactSelectBlock)(NSInteger headerSection);
typedef void(^ContactShowCellBlock)(NSInteger headerSection);

@interface ContactHeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic) IBOutlet UILabel *lblRouterName;
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
//@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

//@property (weak, nonatomic) IBOutlet UIImageView *selectImg;
//@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UIButton *showCellBtn;
//@property (weak, nonatomic) IBOutlet UILabel *titleLab;
//@property (weak, nonatomic) IBOutlet UILabel *detailLab;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImg;

//@property (nonatomic, copy) ContactSelectBlock selectB;
@property (nonatomic, copy) ContactShowCellBlock showCellB;
@property (nonatomic) NSInteger headerSection;

- (void)configHeaderWithModel:(ContactShowModel *)model;

@end

NS_ASSUME_NONNULL_END
