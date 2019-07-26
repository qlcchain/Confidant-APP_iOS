//
//  EmailContentCell.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/12.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "EmailContentCell.h"
//#import <Masonry.h>

@implementation EmailContentCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void) setWebViewHtmlContent:(NSString *) htmlContent
{
    
    // webView直接加载HTMLString
    [_webView loadHTMLString:htmlContent baseURL:nil];
}

@end
