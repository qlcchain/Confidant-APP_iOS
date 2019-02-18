//
//  GuidePageView3.m
//  Qlink
//
//  Created by 旷自辉 on 2018/6/21.
//  Copyright © 2018年 pan. All rights reserved.
//

#import "GuidePageView3.h"

@interface GuidePageView3 ()

@property (weak, nonatomic) IBOutlet UILabel *lab1;
@property (weak, nonatomic) IBOutlet UILabel *lab2;
@property (weak, nonatomic) IBOutlet UILabel *lab3;


@end

@implementation GuidePageView3

- (void)awakeFromNib {
//    _nextBtn.layer.borderColor = [UIColor whiteColor].CGColor;
//    _nextBtn.layer.borderWidth = 1.5f;
//    _nextBtn.layer.cornerRadius = 5.0f;
    [super awakeFromNib];
}

+ (instancetype) loadGuidePageView3 {
    GuidePageView3 *view = [[[NSBundle mainBundle] loadNibNamed:@"GuidePageView3" owner:self options:nil] lastObject];
    [view dataInit];
    return view;
}

- (void)dataInit {
    NSString *str1 = @"Scan the QR code on the Confidant Router to activate your administrator account.";
    NSMutableAttributedString *strAtt1 = [[NSMutableAttributedString alloc] initWithString:str1];
    [strAtt1 setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:UIColorFromRGB(0x89CCF2)} range:NSMakeRange(0, 4)];
    [strAtt1 setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:UIColorFromRGB(0xB3B3B3)} range:NSMakeRange(4, str1.length-4)];
    _lab1.attributedText = strAtt1;
    
    NSString *str2 = @"Scan your QR code of the private key to import an existing account. ";
    NSMutableAttributedString *strAtt2 = [[NSMutableAttributedString alloc] initWithString:str2];
    [strAtt2 setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:UIColorFromRGB(0x89CCF2)} range:NSMakeRange(0, 4)];
    [strAtt2 setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:UIColorFromRGB(0xB3B3B3)} range:NSMakeRange(4, str2.length-4)];
    _lab2.attributedText = strAtt2;
    
    NSString *str3 = @"Scan the invation code to join your friend's Confidant circle.";
    NSMutableAttributedString *strAtt3 = [[NSMutableAttributedString alloc] initWithString:str3];
    [strAtt3 setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:UIColorFromRGB(0x89CCF2)} range:NSMakeRange(0, 4)];
    [strAtt3 setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:UIColorFromRGB(0xB3B3B3)} range:NSMakeRange(4, str3.length-4)];
    _lab3.attributedText = strAtt3;
}

@end
