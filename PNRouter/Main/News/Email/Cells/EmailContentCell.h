//
//  EmailContentCell.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/12.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *EmailContentCellResue = @"EmailContentCell";

@interface EmailContentCell : UITableViewCell
//@property (weak, nonatomic) IBOutlet WKWebView *webView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (void) setWebViewHtmlContent:(NSString *) htmlContent;
@end

NS_ASSUME_NONNULL_END
