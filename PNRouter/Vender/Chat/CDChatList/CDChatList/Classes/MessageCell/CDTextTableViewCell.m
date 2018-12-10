//
//  CDTextTableViewCell.m
//  CDChatList
//
//  Created by chdo on 2017/10/25.
//

#import "CDTextTableViewCell.h"
#import "ChatMacros.h"
#import "CDChatListView.h"
#import "CDLabel.h"
#import "ChatHelpr.h"
#import "ChatListInfo.h"
#import "SocketMessageUtil.h"
#import "RSAUtil.h"
#import "AESCipher.h"

@interface CDTextTableViewCell()<CDLabelDelegate>

/**
 左侧文字label
 */
@property(nonatomic, strong) CDLabel *textContent_left;

/**
 右侧文字label
 */
@property(nonatomic, strong) CDLabel *textContent_right;

@end

@implementation CDTextTableViewCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    // 左侧气泡中添加label
    self.textContent_left = [[CDLabel alloc] init];

    self.textContent_left.frame = CGRectZero;
    
    self.textContent_left.labelDelegate = self;
    [self.bubbleImage_left addSubview:self.textContent_left];
    self.bubbleImage_left.clipsToBounds = NO;
    self.textContent_left.isOwer = NO;
    
    // 右侧气泡中添加label
    self.textContent_right = [[CDLabel alloc] init];
    self.textContent_right.frame = CGRectZero;
    self.textContent_right.labelDelegate = self;
    [self.bubbleImage_right addSubview:self.textContent_right];
    self.bubbleImage_right.clipsToBounds = NO;
    self.textContent_right.isOwer = YES;
    
    // 点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapContent:)];
    [self.bubbleImage_right addGestureRecognizer:tap];
    
    return self;
}

#pragma mark CDLabelDelegate

-(void)labelDidSelectText:(CTLinkData *)link{
    ChatListInfo *info = [ChatListInfo new];
    info.eventType = ChatClickEventTypeTEXT;
    info.msgText = self.msgModal.msg;
    info.containerView = self;
    info.clickedText = link.title;
    info.clickedTextContent = link.url;
    info.range = link.range;
    info.msgModel = self.msgModal;
    if ([self.tableView.msgDelegate respondsToSelector:@selector(chatlistClickMsgEvent:)]) {
        [self.tableView.msgDelegate chatlistClickMsgEvent:info];
    }else{
#ifdef DEBUG
        NSLog(@"[CDChatList] chatlistClickMsgEvent未实现，不能响应点击事件");
#endif
    }
}

- (void) selectMenuWithTag:(NSString *)itemTitle
{
    if ([self.tableView.msgDelegate respondsToSelector:@selector(clickChatMenuItem:withMsgMode:)]) {
        [self.tableView.msgDelegate clickChatMenuItem:itemTitle withMsgMode:self.msgModal];
    }
}

#pragma mark MessageCellDelegate

- (void)configCellByData:(CDChatMessage)data table:(CDChatListView *)table{
    [super configCellByData:data table:table];

    if (data.isLeft) {
        // 左侧
        //     设置消息内容, 并调整UI
        [self configText_Left:data];
    } else {
        // 右侧
        //     设置消息内容, 并调整UI
        [self configText_Right:data];
    }
}

-(void)configText_Left:(CDChatMessage)data{
    
    // 给label复制文字内容
    self.textContent_left.data = data.textlayout;
    CGRect textRect = self.textContent_left.frame;
    textRect.origin = CGPointMake(data.chatConfig.bubbleRoundAnglehorizInset + data.chatConfig.bubbleShareAngleWidth, data.chatConfig.bubbleRoundAnglehorizInset);
    textRect.size = data.textlayout.contents.size;
    self.textContent_left.frame = textRect;
}

-(void)configText_Right:(CDChatMessage)data{

    // 给label复制文字内容
    self.textContent_right.data = data.textlayout;
    CGRect textRect = self.textContent_right.frame;
    textRect.origin = CGPointMake(data.chatConfig.bubbleRoundAnglehorizInset, data.chatConfig.bubbleRoundAnglehorizInset);
    textRect.size = data.textlayout.contents.size;
    self.textContent_right.frame = textRect;
}

-(void)tapContent:(UITapGestureRecognizer *)tap {
    //
    [self hidMenu];
    if (self.msgModal.msgState == CDMessageStateSendFaild
        ) { // 重发
        NSString *msgKey = [RSAUtil privateKeyDecryptValue:self.msgModal.srckey];
        NSString *msg = aesEncryptString(self.msgModal.msg,msgKey);

        NSDictionary *params = @{@"Action":@"SendMsg",@"ToId":self.msgModal.ToId?:@"",@"FromId":self.msgModal.FromId?:@"",@"Msg":msg?:@"",@"SrcKey":self.msgModal.srckey?:@"",@"DstKey":self.msgModal.dskey?:@""};
        [SocketMessageUtil sendChatTextWithParams:params withSendMsgId:self.msgModal.sendMsgId];
    }
}


@end
