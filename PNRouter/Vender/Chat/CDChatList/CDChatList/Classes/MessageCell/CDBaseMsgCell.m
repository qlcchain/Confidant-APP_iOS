//
//  CDBaseMsgCell.m
//  CDChatList
//
//  Created by chdo on 2017/11/2.
//

#import "CDBaseMsgCell.h"
#import "ChatHelpr.h"
#import "UITool.h"
#import "NSDate+Category.h"

@interface CDBaseMsgCell()

@end

@implementation CDBaseMsgCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // 1 消息时间初始化
    _timeLabel = [[UILabel alloc] init];
    [_timeLabel setFrame:CGRectMake(0, 0, 100, 0)];
    _timeLabel.center = CGPointMake(cd_ScreenW() / 2, 0 / 2);
    _timeLabel.text = @"星期一 下午 2:38";
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.backgroundColor = CDHexColor(0xCECECE);
    _timeLabel.layer.cornerRadius = 5;
    _timeLabel.clipsToBounds = YES;
    _timeLabel.font = [UIFont systemFontOfSize:12];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_timeLabel];
    
    // 2 左边 消息内容初始化  头像  气泡
    [self initMessageContent_Left];
    
    // 3 右边 消息内容初始化  头像  气泡
    [self initMessageContent_Right];
    
    return self;
}
#pragma mark 初始化左侧消息UI
-(void)initMessageContent_Left {

    // 视图容器
    _msgContent_left = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:_msgContent_left];
    
    // 选择btn视图
    _chooseMsgBtn_left = [UIButton buttonWithType:UIButtonTypeCustom];
    _chooseMsgBtn_left.frame = CGRectZero;
    [_chooseMsgBtn_left setImage:[UIImage imageNamed:@"icon_unselectmsg"] forState:UIControlStateNormal];
    [_chooseMsgBtn_left setImage:[UIImage imageNamed:@"icon_selectmsg"] forState:UIControlStateSelected];
    [_msgContent_left addSubview:_chooseMsgBtn_left];
    
    // 头像
    UIImage *left_head = ChatHelpr.share.imageDic[ChatHelpr.share.config.icon_head];
    _headImage_left = [[UIImageView alloc] initWithImage:left_head];
    _headImage_left.frame = CGRectZero;
    _headImage_left.contentMode = UIViewContentModeScaleAspectFill;
    [_msgContent_left addSubview:_headImage_left];
    
    // 昵称
    _userName_left = [[UILabel alloc] initWithFrame:CGRectZero];
    _userName_left.textAlignment = NSTextAlignmentLeft;
    _userName_left.textColor = RGB(128, 128, 128);
    _userName_left.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    [_msgContent_left addSubview:_userName_left];
    
    // 气泡
    UIImage *left_box = ChatHelpr.share.imageDic[ChatHelpr.share.config.left_box];
    _bubbleImage_left = [[UIImageView alloc] initWithImage:left_box];
    _bubbleImage_left.userInteractionEnabled = YES;
    _bubbleImage_left.frame = CGRectZero;
    [_msgContent_left addSubview:_bubbleImage_left];
    
    //消息失败icon
    _failLabel_left = [[UILabel alloc] init];
    [_msgContent_left addSubview:_failLabel_left];
    
    if (@available(iOS 8.2, *)) {
        _failLabel_left.font = [UIFont systemFontOfSize:16 weight:UIFontWeightHeavy];
    } else {
        _failLabel_left.font = [UIFont systemFontOfSize:16];
    }
    
    _failLabel_left.text = @"!";
    _failLabel_left.textAlignment = NSTextAlignmentCenter;
    _failLabel_left.textColor = [UIColor whiteColor];
    _failLabel_left.backgroundColor = [UIColor redColor];
    _failLabel_left.clipsToBounds = YES;
    _failLabel_left.layer.cornerRadius = 10;
    _failLabel_left.frame = CGRectMake(0, 0, 20, 20);
    _failLabel_left.center = CGPointMake(_bubbleImage_left.frame.origin.x + _bubbleImage_left.frame.size.width + 20,
                                         _bubbleImage_left.frame.origin.y + _bubbleImage_left.frame.size.height * 0.5);
    
    //发送中的菊花loading
    _indicator_left = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_msgContent_left addSubview:_indicator_left];
    [_indicator_left startAnimating];
    _indicator_left.frame = _failLabel_left.frame;
    _indicator_left.center = _failLabel_left.center;
    
    UITapGestureRecognizer *headTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftheadTapGestureAction:)];
    _headImage_left.userInteractionEnabled = YES;
    [_headImage_left addGestureRecognizer:headTapGesture];
    
    UILongPressGestureRecognizer *headLongGesture= [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(leftheadLongGestureAction:)];
    [_headImage_left addGestureRecognizer:headLongGesture];
    
}
#pragma mark 初始化右侧消息UI
-(void)initMessageContent_Right{
    
    // 视图容器
    _msgContent_right = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:_msgContent_right];
    
    // 选择btn视图
    _chooseMsgBtn_right = [UIButton buttonWithType:UIButtonTypeCustom];
    _chooseMsgBtn_right.frame = CGRectZero;
    [_chooseMsgBtn_right setImage:[UIImage imageNamed:@"icon_unselectmsg"] forState:UIControlStateNormal];
    [_chooseMsgBtn_right setImage:[UIImage imageNamed:@"icon_selectmsg"] forState:UIControlStateSelected];
    [_msgContent_right addSubview:_chooseMsgBtn_right];
    
    // 头像
    UIImage *right_head = ChatHelpr.share.imageDic[ChatHelpr.share.config.icon_head];
    _headImage_right = [[UIImageView alloc] initWithImage:right_head];
    _headImage_right.frame = CGRectZero;
    _headImage_right.contentMode = UIViewContentModeScaleAspectFill;
    [_msgContent_right addSubview:_headImage_right];
    
    // 昵称
    _userName_right = [[UILabel alloc] initWithFrame:CGRectZero];
    _userName_right.textAlignment = NSTextAlignmentRight;
    _userName_right.textColor = RGB(102, 102, 102);
    _userName_right.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    [_msgContent_right addSubview:_userName_right];
    
    // 气泡
    UIImage *right_box = ChatHelpr.share.imageDic[ChatHelpr.share.config.right_box];
    _bubbleImage_right = [[UIImageView alloc] initWithImage:right_box];
    _bubbleImage_right.userInteractionEnabled = YES;
    _bubbleImage_right.frame = CGRectZero;
    [_msgContent_right addSubview:_bubbleImage_right];
    
    _statuImgView_right = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Send out_t"]];
    [_msgContent_right addSubview:_statuImgView_right];
    
    //消息失败icon
    _failLabel_right = [[UILabel alloc] init];
    [_msgContent_right addSubview:_failLabel_right];
    if (@available(iOS 8.2, *)) {
        _failLabel_right.font = [UIFont systemFontOfSize:16 weight:UIFontWeightHeavy];
    } else {
        _failLabel_right.font = [UIFont systemFontOfSize:16];
    }
    
    _failLabel_right.text = @"!";
    _failLabel_right.textAlignment = NSTextAlignmentCenter;
    _failLabel_right.textColor = [UIColor whiteColor];
    _failLabel_right.backgroundColor = [UIColor redColor];
    _failLabel_right.clipsToBounds = YES;
    _failLabel_right.layer.cornerRadius = 10;
    _failLabel_right.frame = CGRectMake(0, 0, 20, 20);
    _failLabel_right.center = CGPointMake(_bubbleImage_right.frame.origin.x - 40,
                                          _bubbleImage_right.frame.size.height * 0.5);
    
    //发送中的菊花loading
    _indicator_right = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_msgContent_right addSubview:_indicator_right];
    [_indicator_right startAnimating];
    
    _indicator_right.frame = _failLabel_right.frame;
    _indicator_right.center = _failLabel_right.center;
    
//    UITapGestureRecognizer *headTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rightheadTapGestureAction:)];
//    _headImage_right.userInteractionEnabled = YES;
//    [_headImage_right addGestureRecognizer:headTapGesture];
}

#pragma mark 根据消息中的cellHeight  bubbleWidth 更新左侧UI
/**
 根据消息中的cellHeight  bubbleWidth 更新UI
 
 @param data 消息体
 */
-(void)updateMsgContentFrame_left:(CDChatMessage) data{
    
    // 选择btn视图
    CGFloat selectBtnWidth = 44;
    CGFloat btnTop = 8;
    if (data.showSelectMsg == 0) {
        _chooseMsgBtn_left.frame = CGRectZero;
    } else if (data.showSelectMsg == 1) {
        _chooseMsgBtn_left.frame = CGRectMake(0, btnTop, selectBtnWidth, selectBtnWidth);
        _chooseMsgBtn_left.selected = NO;
    } else if (data.showSelectMsg == 2) {
        _chooseMsgBtn_left.frame = CGRectMake(0, btnTop, selectBtnWidth, selectBtnWidth);
        _chooseMsgBtn_left.selected = YES;
    }
    
    // 头像
    if (data.userThumImage || data.userThumImageURL){
//        _headImage_left.frame = CGRectMake(data.chatConfig.messageMargin, data.chatConfig.messageMargin, data.chatConfig.headSideLength, data.chatConfig.headSideLength);
        CGFloat top = data.userName.length == 0 ? data.chatConfig.messageMarginBottomOfTime : data.chatConfig.messageMarginBottomOfTime+5;
        _headImage_left.frame = CGRectMake(_chooseMsgBtn_left.cd_right + data.chatConfig.headMargin, top, data.chatConfig.headSideLength, data.chatConfig.headSideLength);
    } else {
//        _headImage_left.frame = CGRectZero;
        _headImage_left.frame = CGRectMake(_chooseMsgBtn_left.cd_right, 0, 0, 0);
    }
    _headImage_left.layer.cornerRadius = _headImage_left.width/2.0;
    _headImage_left.layer.masksToBounds = YES;
    
    // 昵称
//    _userName_left.frame = CGRectMake(data.chatConfig.messageMargin + _headImage_left.cd_width + data.chatConfig.bubbleShareAngleWidth, 0, data.chatConfig.bubbleMaxWidth, data.chatConfig.nickNameHeight);

    _userName_left.frame = CGRectMake(data.chatConfig.headMargin + _headImage_left.cd_width + data.chatConfig.bubbleShareAngleWidth+2, data.chatConfig.messageMarginBottomOfTime, data.chatConfig.bubbleMaxWidth, data.chatConfig.nickNameHeight);
    
    // 左侧
    // 设置消息内容的总高度
    CGRect msgRect = self.msgContent_left.frame;
    CGFloat msgContentHeight = data.cellHeight;
    
    // 根据是否显示时间，调整msgContent_left位置
    if (data.willDisplayTime) {
        msgRect.origin = CGPointMake(0, data.chatConfig.msgTimeH);
        msgContentHeight = msgContentHeight - data.chatConfig.msgTimeH; //
    } else {
        msgRect.origin = CGPointZero;
    }
    msgRect.size.width = cd_ScreenW();
    msgRect.size.height = msgContentHeight;
    self.msgContent_left.frame = msgRect;
    
    
    // 更新消息气泡的高度和宽度
    CGRect bubbleRec = self.bubbleImage_left.frame;
    bubbleRec.origin.x = data.chatConfig.headMargin * 2 + _headImage_left.cd_right - data.chatConfig.headMargin - data.chatConfig.bubbleShareAngleWidth;
    bubbleRec.origin.y = data.userName.length == 0 ? data.chatConfig.messageMarginBottomOfTime : data.chatConfig.messageMarginBottomOfTime + data.chatConfig.nickNameHeight;
    
    bubbleRec.size.width = data.bubbleWidth;
    if (data.userName.length == 0) {
        bubbleRec.size.height = msgContentHeight - data.chatConfig.messageMarginBottomOfTime - data.chatConfig.messageMarginBottom;
    } else {
        bubbleRec.size.height = msgContentHeight - data.chatConfig.messageMarginBottomOfTime - data.chatConfig.nickNameHeight - data.chatConfig.messageMarginBottom;
    }
    
    self.bubbleImage_left.frame = bubbleRec;
    
    // 更新loading位置
    _indicator_left.frame = CGRectMake(0, 0, 20, 20);
    _indicator_left.center = CGPointMake(_bubbleImage_left.frame.origin.x + _bubbleImage_left.frame.size.width + 20,
                                         _bubbleImage_left.frame.origin.y + _bubbleImage_left.frame.size.height * 0.5);
    
    // 更新faillabel位置
    _failLabel_left.frame = _indicator_left.frame;
    _failLabel_left.center = _indicator_left.center;
    
    // 更新动画状态
    // 更新动画状态
    if (data.msgState == CDMessageStateNormal) {
        [_indicator_left stopAnimating];
        [_failLabel_left setHidden: YES];
    } else if (data.msgState == CDMessageStateSending) {
        [_indicator_left startAnimating];
        [_failLabel_left setHidden: YES];
    } else if (data.msgState == CDMessageStateSendFaild ||
               data.msgState == CDMessageStateDownloadFaild) {
        [_indicator_left stopAnimating];
        [_failLabel_left setHidden: NO];
    } else if (data.msgState == CDMessageStateDownloading) {
        [_indicator_left startAnimating];
        [_failLabel_left setHidden: YES];
    }
}

#pragma mark 根据消息中的cellHeight  bubbleWidth 更新右侧UI
/**
 根据消息中的cellHeight  bubbleWidth 更新UI
 
 @param data 消息体
 */
-(void)updateMsgContentFrame_right:(CDChatMessage) data{
    
    // 选择btn视图
    CGFloat selectBtnWidth = 44;
    CGFloat btnTop = 8;
    if (data.showSelectMsg == 0) {
        _chooseMsgBtn_right.frame = CGRectZero;
    } else if (data.showSelectMsg == 1) {
        _chooseMsgBtn_right.frame = CGRectMake(0, btnTop, selectBtnWidth, selectBtnWidth);
        _chooseMsgBtn_right.selected = NO;
    } else if (data.showSelectMsg == 2) {
        _chooseMsgBtn_right.frame = CGRectMake(0, btnTop, selectBtnWidth, selectBtnWidth);
        _chooseMsgBtn_right.selected = YES;
    }
    
    // 头像
    if (data.userThumImage || data.userThumImageURL){
        _headImage_right.frame = CGRectMake(cd_ScreenW() - (data.chatConfig.headSideLength + data.chatConfig.headMargin), data.chatConfig.messageMarginBottomOfTime, data.chatConfig.headSideLength, data.chatConfig.headSideLength);
    } else {
        _headImage_right.frame = CGRectMake(cd_ScreenW(), data.chatConfig.messageMarginBottomOfTime, 0, data.chatConfig.headSideLength);
    }
    _headImage_right.layer.cornerRadius = _headImage_right.width/2.0;
    _headImage_right.layer.masksToBounds = YES;
    
    // 昵称
    _userName_right.frame = CGRectMake(_headImage_right.cd_left - data.chatConfig.headMargin - data.chatConfig.bubbleMaxWidth, 0, data.chatConfig.bubbleMaxWidth, data.chatConfig.nickNameHeight);
    _userName_right.textColor = data.chatConfig.nickNameColor;
    
    // 右侧
    // 设置消息内容的总高度
    CGRect msgRect = self.msgContent_right.frame;
    CGFloat msgContentHeight = data.cellHeight;
    if (data.willDisplayTime) {
        msgRect.origin = CGPointMake(0, data.chatConfig.msgTimeH);
        msgContentHeight = msgContentHeight - data.chatConfig.msgTimeH; //
    } else {
        msgRect.origin = CGPointZero;
    }
    
    msgRect.size.width = cd_ScreenW();
    
    msgRect.size.height = msgContentHeight;
    self.msgContent_right.frame = msgRect;
    
    // 更新气泡的高度和宽度
    CGRect bubbleRec = self.bubbleImage_right.frame;
    bubbleRec.origin.x = cd_ScreenW() - (data.bubbleWidth + _headImage_right.cd_width) - data.chatConfig.headMargin * 2 + data.chatConfig.bubbleShareAngleWidth;
    bubbleRec.origin.y = data.userName.length == 0 ? data.chatConfig.messageMarginBottomOfTime : data.chatConfig.messageMarginBottomOfTime + data.chatConfig.nickNameHeight;
    bubbleRec.size.width = data.bubbleWidth;
    if (data.userName.length == 0) {
        bubbleRec.size.height = msgContentHeight - data.chatConfig.messageMarginBottomOfTime - data.chatConfig.messageMarginBottom;
    } else {
        bubbleRec.size.height = msgContentHeight - data.chatConfig.messageMarginBottomOfTime - data.chatConfig.nickNameHeight;
    }
    if (data.msgType == CDMessageTypeText) {
        // bubbleRec.size.height += 10;
    }
    
    [self stopAnimation];
    if (data.messageStatu == 1 || data.messageStatu == 0) {
        _statuImgView_right.image = [UIImage imageNamed:@"Send out_h"];
    } else if (data.messageStatu == 2){
        _statuImgView_right.image = [UIImage imageNamed:@"Send out_t"];
    } else {
        _statuImgView_right.image = [UIImage imageNamed:@"Send out_n"];
        [self startAnimation];
    }
    _statuImgView_right.frame = CGRectMake(bubbleRec.origin.x+bubbleRec.size.width-25,bubbleRec.origin.y+ bubbleRec.size.height-18, 16, 16);
   
    self.bubbleImage_right.frame = bubbleRec;
    
    // 设置loading位置
    _indicator_right.frame = CGRectMake(0, 0, 20, 20);
    _indicator_right.center = CGPointMake(_bubbleImage_right.frame.origin.x - 20,
                                          _bubbleImage_right.frame.origin.y + _bubbleImage_right.frame.size.height * 0.5);
    // 更新faillabel位置
    _failLabel_right.frame = _indicator_right.frame;
    _failLabel_right.center = _indicator_right.center;
    
    // 更新动画状态
    if (data.msgState == CDMessageStateNormal) {
        [_indicator_right stopAnimating];
        [_failLabel_right setHidden: YES];
    } else if (data.msgState == CDMessageStateSending) {
        [_indicator_right startAnimating];
        [_failLabel_right setHidden: YES];
    } else if (data.msgState == CDMessageStateSendFaild ||
               data.msgState == CDMessageStateDownloadFaild) {
        [_indicator_right stopAnimating];
        [_failLabel_right setHidden: NO];
    } else if (data.msgState == CDMessageStateDownloading) {
        [_indicator_right startAnimating];
        [_failLabel_right setHidden: YES];
    }
}

- (void)startAnimation

{
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
     rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    
     rotationAnimation.duration = 1.5;
    
     rotationAnimation.cumulative = YES;
    
     rotationAnimation.repeatCount = HUGE_VALF;
    
     [_statuImgView_right.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
}

- (void)stopAnimation

{
    
    [_statuImgView_right.layer removeAllAnimations];
    
}


#pragma mark 设置消息data
-(void)configCellByData:(CDChatMessage)data table:(CDChatListView *)table{
    
    self.backgroundColor = data.chatConfig.msgBackGroundColor;
    
    self.msgModal = data;
    self.tableView = table;
    
    // 设置显示或隐藏  左右气泡
    [self.msgContent_left setHidden:!data.isLeft];
    self.msgContent_left.backgroundColor = data.chatConfig.msgContentBackGroundColor;
    [self.msgContent_right setHidden:data.isLeft];
    self.msgContent_right.backgroundColor = data.chatConfig.msgContentBackGroundColor;
    
    // 设置头像
    _headImage_right.backgroundColor = data.chatConfig.headBackGroundColor;
    _headImage_left.backgroundColor = data.chatConfig.headBackGroundColor;
    
    
    
    if (data.userThumImage || data.userThumImageURL){
        if (data.isLeft) {
            if (data.userThumImage) {
                _headImage_left.image = data.userThumImage;
            } else if (data.userThumImageURL) {
                [_headImage_left sd_setImageWithURL:[NSURL URLWithString:data.userThumImageURL] placeholderImage:ChatHelpr.share.imageDic[ChatHelpr.share.config.icon_head]];
            } else {
                [_headImage_left setImage:ChatHelpr.share.imageDic[ChatHelpr.share.config.icon_head]];
            }
        } else {
            if (data.userThumImage) {
                _headImage_right.image = data.userThumImage;
            } else if (data.userThumImageURL) {
                [_headImage_right sd_setImageWithURL:[NSURL URLWithString:data.userThumImageURL] placeholderImage:ChatHelpr.share.imageDic[ChatHelpr.share.config.icon_head]];
            } else {
                [_headImage_right setImage:ChatHelpr.share.imageDic[ChatHelpr.share.config.icon_head]];
            }
        }
    }
    
    // 设置昵称
    if (data.isLeft) {
        _userName_left.text = data.userName;
    } else {
        _userName_right.text = data.userName;
    }
    
    // 设置顶部时间Label
    NSDate *date;
    date = [NSDate dateWithTimeIntervalSince1970:data.TimeStatmp ];
    NSString *timeStr = [self checkDateDisplay:date msg:data];
    self.timeLabel.text = timeStr;
    CGSize textSize = [self.timeLabel.text boundingRectWithSize:CGSizeMake(cd_ScreenW(), data.chatConfig.msgTimeH) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: self.timeLabel.font} context:nil].size;
    if (textSize.height < data.chatConfig.msgTimeH) {
        textSize.height = data.chatConfig.msgTimeH;
    }
//    data.chatConfig.alwaysShowMsgTime = YES;
    [_timeLabel setFrame:CGRectMake(0, 0, textSize.width + data.chatConfig.sysInfoPadding * 2, textSize.height)];
    _timeLabel.center = CGPointMake(cd_ScreenW() / 2, data.chatConfig.msgTimeH / 2);
    
    if (data.isLeft) {
        [self updateMsgContentFrame_left:data];
    } else {
        [self updateMsgContentFrame_right:data];
    }
}

#pragma mark 根据消息时间，计算需要显示的消息时间格式
/**
 根据消息时间，计算需要显示的消息时间格式
 
 @param thisDate 消息时间
 @return 显示在label上的
 */
- (NSString*)checkDateDisplay:(NSDate *)thisDate msg:(CDChatMessage)data{
    
    if (!data.ctDataconfig.matchLink) {
        NSDateFormatter *formate = [[NSDateFormatter alloc] init];
        formate.dateFormat = @"MM-dd HH:mm";
        return [formate stringFromDate:thisDate];
    }
    
    return [thisDate chatTimeDescription];
    
    /*
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    NSDate *nowDate =  [NSDate date];
    
    // IOS8 最低支持；
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekOfYear;
    
    NSDateComponents *nowComps = [[NSDateComponents alloc] init];
    nowComps = [calendar components:unitFlags fromDate:nowDate];
    NSInteger nowDay = nowComps.day;
    
    // 时间戳  转 是日期
    NSDateComponents *thisComps = [[NSDateComponents alloc] init];
    thisComps = [calendar components:unitFlags fromDate:thisDate];
    NSInteger thisDay = thisComps.day;
    
    // 当前时间差；
    NSDateComponents *dayDiffComps = [[NSDateComponents alloc] init] ;
    dayDiffComps = [calendar components:NSCalendarUnitDay fromDate:thisDate toDate:nowDate options:NSCalendarWrapComponents];
    NSInteger compareDay = dayDiffComps.day;
    
    NSString *timeString;
    
    // 是否 是当天 的 时间；
    if (compareDay == 0 && nowDay == thisDay) {
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH:mm"];
        timeString  = [dateFormat stringFromDate:thisDate];
        return timeString;
    }
    
    // 是否  昨天时间；
    if (compareDay == 1 || (compareDay == 0 && nowDay != thisDay) ){
        timeString = @"yesterday";
        
        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"HH:mm"];
        NSString* time = [dateFormat stringFromDate:thisDate];
        timeString = [NSString stringWithFormat:@"%@ %@" , timeString , time ];
        
        return timeString;
    }
    
    // 是否  前天时间；
//    if (compareDay == 2 || (compareDay == 0 && nowDay != thisDay) ){
//        timeString = @"前天";
//
//        NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
//        [dateFormat setDateFormat:@"HH:mm"];
//        NSString* time = [dateFormat stringFromDate:thisDate];
//        timeString = [NSString stringWithFormat:@"%@ %@" , timeString , time ];
//
//        return timeString;
//    }
    
    NSDateFormatter *formate = [[NSDateFormatter alloc] init];
    formate.dateFormat = @"MM-dd HH:mm";
    return [formate stringFromDate:thisDate];
    
    // 非近 一周时间 ；
//    NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"MM-dd"];
//    timeString  = [dateFormat stringFromDate:thisDate];
//
//    [dateFormat setDateFormat:@"yy/MM/dd"];
//    timeString  = [dateFormat stringFromDate:thisDate];
    */
    
}


-(void)showMenuWithItemX:(CGFloat) itemx{
    
    if ([self canBecomeFirstResponder]) {
        [self becomeFirstResponder];
    }
    
    NSMutableArray *itmes = [NSMutableArray array];
    
    if (self.msgModal.msgType != CDMessageTypeAudio) {
        UIMenuItem *item1 = [[UIMenuItem alloc] initWithTitle:@"Forward" action:@selector(selectForwardItem:)];
        [itmes addObject:item1];
    }
   
    if (!self.msgModal.isLeft) {
        UIMenuItem *item1 = [[UIMenuItem alloc] initWithTitle:@"Withdraw" action:@selector(selectWithdrawItem:)];
        [itmes addObject:item1];
    } else {
        if (self.msgModal.isAdmin == GROUP_IDF) { //是群主
            UIMenuItem *item1 = [[UIMenuItem alloc] initWithTitle:@"Withdraw" action:@selector(selectWithdrawItem:)];
            [itmes addObject:item1];
        }
    }
    
    if (self.msgModal.msgType == CDMessageTypeImage || self.msgModal.msgType == CDMessageTypeMedia) {
        UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:@"Save" action:@selector(selectDownloadItem:)];
        [itmes addObject:item];
    }
    
    if (self.msgModal.msgType == CDMessageTypeImage) {
        UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:@"Share" action:@selector(selectShareItem:)];
        [itmes addObject:item];
    }
    
    if (self.msgModal.msgType == CDMessageTypeFile || self.msgModal.isLeft) {
        UIMenuItem *item = [[UIMenuItem alloc] initWithTitle:@"React" action:@selector(selectReactItem:)];
        [itmes addObject:item];
    }
    
    
    
    if (itmes.count > 0) {
        UIMenuController *menu = [UIMenuController sharedMenuController];
         [menu setMenuItems:itmes];
        if (self.msgModal.isLeft) {
            itemx = self.bubbleImage_left.frame.origin.x+itemx;
        } else {
            itemx = self.bubbleImage_right.frame.origin.x+itemx;
        }
        CGFloat itemY = 10;
        if (self.msgModal.willDisplayTime) {
            itemY += self.msgModal.chatConfig.msgTimeH;
        }
        
        CGRect rec = CGRectMake(itemx ,itemY, 10, 10);
        [menu setTargetRect:rec inView:self.msgContent_left];
        [menu setMenuVisible:YES animated:YES];
    }
    
    
}
-(void)hidMenu{
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuVisible:NO animated:YES];
}

- (void) selectWithdrawItem:(UIMenuController *) item
{
    if (self.tableView.msgDelegate) {
        [self.tableView.msgDelegate clickChatMenuItem:@"Withdraw" withMsgMode:self.msgModal];
    }
    
}
- (void) selectShareItem:(UIMenuController *) item
{
    if (self.tableView.msgDelegate) {
        [self.tableView.msgDelegate clickChatMenuItem:@"Share" withMsgMode:self.msgModal];
    }
}
- (void) selectForwardItem:(UIMenuController *) item
{
    if (self.tableView.msgDelegate) {
        [self.tableView.msgDelegate clickChatMenuItem:@"Forward" withMsgMode:self.msgModal];
    }
}

- (void)selectDownloadItem:(UIMenuController *)item {
    if (self.tableView.msgDelegate) {
        [self.tableView.msgDelegate clickChatMenuItem:@"Save" withMsgMode:self.msgModal];
    }
}
- (void) selectReactItem:(UIMenuController *) item
{
    if (self.tableView.msgDelegate) {
        [self.tableView.msgDelegate clickChatMenuItem:@"React" withMsgMode:self.msgModal];
    }
}


#pragma mark ---点击头像手势
- (void) rightheadTapGestureAction:(UIGestureRecognizer *) gesture
{
    if (self.tableView.msgDelegate) {
        [self.tableView.msgDelegate clickHeadWithMessage:self.msgModal];
    }
}
- (void) leftheadTapGestureAction:(UIGestureRecognizer *) gesture
{
     [self.tableView.msgDelegate clickHeadWithMessage:self.msgModal];
}
- (void) leftheadLongGestureAction:(UIGestureRecognizer *) gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            if ([self.tableView.msgDelegate respondsToSelector:@selector(longPressHeadWithMessage:)]) {
                [self.tableView.msgDelegate longPressHeadWithMessage:self.msgModal];
            }
            break;
            
        default:
            break;
    }
}
@end
