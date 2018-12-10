//
//  CDLabel.h
//  CDLabel
//
//  Created by chdo on 2017/12/1.
//

#import <UIKit/UIKit.h>
#import "CTData.h"
#import <CoreText/CoreText.h>
#import "CTHelper.h"

@protocol CDLabelDelegate <NSObject>
-(void)labelDidSelectText:(CTLinkData *)link;
-(void)selectMenuWithTag:(NSString *) itemTitle;
@end


@interface CDLabel : UIView


@property (assign, nonatomic) CTDataConfig config;

@property (weak, nonatomic) id<CDLabelDelegate> labelDelegate;

@property (strong, nonatomic) CTData * data;

@property (strong, nonatomic) NSString *text;

@property (assign, nonatomic) BOOL isOwer;

@property (strong, nonatomic) NSAttributedString *attributedText;

@end
