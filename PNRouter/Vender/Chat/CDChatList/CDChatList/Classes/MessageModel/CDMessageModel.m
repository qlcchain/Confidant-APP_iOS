//
//  CDMessageModel.m
//  CDChatList
//
//  Created by chdo on 2018/3/20.
//

#import "CDMessageModel.h"

@implementation CDMessageModel

@synthesize bubbleWidth;

@synthesize userThumImage;

@synthesize willDisplayTime;

@synthesize messageId;

@synthesize msg;

@synthesize isLeft;

@synthesize msgType;

@synthesize createTime;

@synthesize textlayout;

@synthesize modalInfo;

@synthesize msgState;

@synthesize cellHeight;

@synthesize userThumImageURL;

@synthesize audioSufix;

@synthesize audioText;

@synthesize audioTime;

@synthesize userName;

@synthesize sendMsgId;

@synthesize ctDataconfig;

@synthesize chatConfig;

@synthesize reuseIdentifierForCustomeCell;

@synthesize FromId;
@synthesize ToId;
@synthesize fileSize;
@synthesize TimeStatmp;
@synthesize showSelectMsg;
@synthesize mediaImage;
@synthesize fileID;
@synthesize fileName;
@synthesize filePath;
@synthesize srckey;
@synthesize dskey;
@synthesize publicKey;
@synthesize messageStatu;
@synthesize isDown;
@synthesize signKey;
@synthesize nonceKey;
@synthesize symmetKey;
@synthesize fileWidth;
@synthesize fileHeight;
@synthesize fileMd5;
@synthesize isGroup;
@synthesize fileKey;
@synthesize isAdmin;
@synthesize AssocId;
@synthesize repModel;
@synthesize isEmailRead;

-(instancetype)init:(NSDictionary *)dic{
    self = [super init];
    
    self.msg  = dic[@"msg"];
    self.msgType = [dic[@"msgType"] integerValue];
    if (dic[@"isLeft"]) {
        self.isLeft = [dic[@"isLeft"] integerValue];
    }
    
    if (dic[@""]) {
        
    }
    
    return self;
}
@end
