//
//  CDSystemTableViewCell.m
//  CDChatList
//
//  Created by chdo on 2017/11/13.
//

#import "CDSystemTableViewCell.h"
#import "ChatMacros.h"
#import "CDBaseMsgCell.h"
#import "ChatHelpr.h"
#import "UITool.h"
@interface CDSystemTableViewCell()
@property(nonatomic, strong) UIView  *infoBackGround;
@property(nonatomic, strong) UILabel *sysInfoLbael;
@end

@implementation CDSystemTableViewCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
  
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.infoBackGround = [[UIView alloc] init];
    self.infoBackGround.backgroundColor = [UIColor clearColor];
    [self addSubview:self.infoBackGround];
    
    self.sysInfoLbael = [[UILabel alloc] init];
    //    self.sysInfoLbael.font = SysInfoMessageFont;
    self.sysInfoLbael.textAlignment = NSTextAlignmentCenter;
    self.sysInfoLbael.textColor = [UIColor whiteColor];
    self.sysInfoLbael.numberOfLines = 0;
    self.sysInfoLbael.backgroundColor = CDHexColor(0xCECECE);
    self.sysInfoLbael.clipsToBounds = YES;
    self.sysInfoLbael.layer.cornerRadius = 5;
    
    [self.infoBackGround addSubview:self.sysInfoLbael];
    
    return self;
}

- (void)configCellByData:(CDChatMessage)data table:(CDChatListView *)table{
    
    
    self.backgroundColor = data.chatConfig.msgBackGroundColor;
    self.infoBackGround.frame = CGRectMake(0, 0, data.bubbleWidth, data.cellHeight);
    self.infoBackGround.center = CGPointMake(cd_ScreenW() / 2, data.cellHeight / 2);
    
    self.sysInfoLbael.text = data.msg;
    self.sysInfoLbael.font = data.chatConfig.sysInfoMessageFont;
    self.sysInfoLbael.frame = CGRectMake(0, 0, data.bubbleWidth - data.chatConfig.sysInfoPadding, data.cellHeight - data.chatConfig.sysInfoPadding);
    self.sysInfoLbael.center = CGPointMake(data.bubbleWidth / 2, data.cellHeight / 2);
    
}

@end
