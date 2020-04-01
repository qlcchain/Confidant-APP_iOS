//
//  PNContactViewController.m
//  MyConfidant
//
//  Created by 旷自辉 on 2020/1/7.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "PNContactViewController.h"
#import <Contacts/Contacts.h>
#import "SystemUtil.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "AESCipher.h"
#import "NSDate+Category.h"
#import "SocketDataUtil.h"
#import "SocketManageUtil.h"
#import "UserModel.h"
#import "RequestService.h"
#import <LibsodiumSDK/LibsodiumUtil.h>
#import "PNFileUploadModel.h"

@interface PNContactViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblLocalCount;
@property (weak, nonatomic) IBOutlet UILabel *lblNodeCount;
@property (weak, nonatomic) IBOutlet UIButton *nodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *localBtn;
@property (nonatomic, strong) NSMutableArray *nodeContacts;

@property (nonatomic, assign) BOOL isPermissionContacts;
@property (nonatomic, strong) NSString *nodeContactCount;
@property (nonatomic, strong) NSString *nodeContactPath;
@property (nonatomic, strong) NSString *nodeContactKey;
@property (nonatomic, strong) NSData *nodeContactData;

@property (nonatomic, assign) NSInteger localContactCount;

@end


@implementation PNContactViewController
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self requestContactAuthorAfterSystemVersion9];
}

- (IBAction)clickBackAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}
- (IBAction)clickUploadNodeAction:(id)sender {
    if (!self.isPermissionContacts) {
        [self showAlertViewAboutNotAuthorAccessContact];
    } else {
         [self jumpUploadNodeActionSheet];
    }
   
}
- (IBAction)clickImportPhoneAction:(id)sender {
    if (!self.isPermissionContacts) {
        [self showAlertViewAboutNotAuthorAccessContact];
    } else if (![self.nodeContactPath isEmptyString]) {
        [self jumpImportActionSheet];
    } else {
        [self.view showHint:@"The contacts haven't been backuped to Node. You may sync to Node firstly."];
    }
    
}
- (instancetype)initWithNodePath:(NSString *)contactPath nodeKey:(NSString *)contactKey nodeCount:(NSString *)contactCount isPermission:(BOOL)isPerssion loaclContactCount:(NSInteger)localContactCount
{
    if (self = [super init]) {
        self.isPermissionContacts = isPerssion;
        self.nodeContactKey = contactKey?:@"";
        self.nodeContactPath = contactPath?:@"";
        self.nodeContactCount = contactCount?:@"0";
        self.localContactCount = localContactCount;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = MAIN_GRAY_COLOR;
    _nodeBtn.layer.cornerRadius = 8.0f;
    _localBtn.layer.cornerRadius = 8.0f;
    _localBtn.layer.borderColor = MAIN_PURPLE_COLOR.CGColor;
    _localBtn.layer.borderWidth = 1.0f;
    
    _lblLocalCount.text = [NSString stringWithFormat:@"%ld",_localContactCount];
    _lblNodeCount.text = self.nodeContactCount;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadContactsSuccessNoti:) name:Photo_File_Upload_Success_Noti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactsUploadFileDataNoti:) name:Upload_Contacts_Data_Success_Noti object:nil];

    
}

#pragma mark -----------layz
- (NSMutableArray *)nodeContacts
{
    if (!_nodeContacts) {
        _nodeContacts = [NSMutableArray array];
    }
    return _nodeContacts;
}

#pragma mark--------------弹出上传通讯录选项
- (void) jumpUploadNodeActionSheet
{
    @weakify_self
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *alert1 = [UIAlertAction actionWithTitle:@"Sync (merge the Node contacts)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf uploadContactsToNodeWithTag:1];
    }];
    UIAlertAction *alert2 = [UIAlertAction actionWithTitle:@"Sync (replace the Node contacts)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf uploadContactsToNodeWithTag:2];
    }];
    [alert1 setValue:RGB(102, 70, 274) forKey:@"_titleTextColor"];
    [alert2 setValue:RGB(102, 70, 274) forKey:@"_titleTextColor"];
    [alertC addAction:alert1];
    [alertC addAction:alert2];
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertC addAction:alertCancel];
    [alertCancel setValue:RGB(102, 70, 274) forKey:@"_titleTextColor"];
    [self presentViewController:alertC animated:YES completion:nil];
}
#pragma mark -------------弹出备份选项
- (void) jumpImportActionSheet
{
   @weakify_self
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *alert1 = [UIAlertAction actionWithTitle:@"Recover (merge to local contacts)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf jumpAlertConfirmWithTag:1];
    }];
    UIAlertAction *alert2 = [UIAlertAction actionWithTitle:@"Recover (replace all local contacts)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf jumpAlertConfirmWithTag:2];
    }];
    [alert1 setValue:RGB(102, 70, 274) forKey:@"_titleTextColor"];
    [alert2 setValue:RGB(102, 70, 274) forKey:@"_titleTextColor"];
    [alertC addAction:alert1];
    [alertC addAction:alert2];
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertC addAction:alertCancel];
    [alertCancel setValue:RGB(102, 70, 274) forKey:@"_titleTextColor"];
    [self presentViewController:alertC animated:YES completion:nil];
}

/// 恢复通讯录弹框提示
/// @param tag 1:合并 2:替换
- (void) jumpAlertConfirmWithTag:(NSInteger) tag
{
    NSString *alertTitle = @"Recover to local";
    NSString *alertContent = @"";
    if (tag == 1) { // 合拼
        alertContent = @"Are you sure you want to merge Node contacts to local contacts?";
    } else { // 替换
        alertContent = @"The local contacts will be replaced by the Node contacts. Are you sure you want to continue?";
    }
    UIAlertController *alertController = [UIAlertController
        alertControllerWithTitle:alertTitle
        message:alertContent
        preferredStyle: UIAlertControllerStyleAlert];

    @weakify_self
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf importContactsVCFWithTag:tag];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:OKAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


/// 上传通讯录到节点
/// @param tag 1:更新 2:替换
- (void) uploadContactsToNodeWithTag:(NSInteger) tag
{
    // 获取本地通讯录
    NSMutableArray*contacts = [NSMutableArray array];
    CNContactStore*store = [[CNContactStore alloc] init];
    NSError*fetchError;
    CNContactFetchRequest*request = [[CNContactFetchRequest alloc]initWithKeysToFetch:@[[CNContactVCardSerialization descriptorForRequiredKeys],[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName]]];

    BOOL success = [store enumerateContactsWithFetchRequest:request error:&fetchError usingBlock:^(CNContact*contact,BOOL*stop) {
        [contacts addObject:contact];
    }];
    
    if (!success) {
        [self.view showHint:@"The operation failed. Please try again later."];
        return;
    }
    if (contacts.count == 0) {
        [self.view showHint:@"There is no contacts has been backuped to Local. You may create new contacts and then sync to Node."];
        return;
    }
    
    [self.view showHudInView:self.view hint:@"Sync..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    
    if (tag ==1 && [self.nodeContactCount integerValue]>0) { // 更新节点通讯录
        
        NSString *fileName = [[UserModel getUserModel].userSn stringByAppendingString:@".vcf"];
        NSString *downloadFilePath = [SystemUtil getTempDeFilePath:fileName];
                  
        if (![SystemUtil filePathisExist:downloadFilePath]) {
            @weakify_self
            [RequestService downFileWithBaseURLStr:self.nodeContactPath filePath:downloadFilePath progressBlock:^(CGFloat progress) {
                
            } success:^(NSURLSessionDownloadTask *dataTask, NSString *filePath) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
                    [weakSelf deFileWithFileData:fileData withUploadNode:YES withDelContactTag:tag withLocalContacts:contacts];
                });
               
                
            } failure:^(NSURLSessionDownloadTask *dataTask, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SystemUtil removeDocmentFilePath:downloadFilePath];
                    [weakSelf.view hideHud];
                    [weakSelf.view showHint:@"File download failed."];
                });
                
            }];
        } else {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSData *contactData = [NSData dataWithContentsOfFile:downloadFilePath];
                [self deFileWithFileData:contactData withUploadNode:YES withDelContactTag:tag withLocalContacts:contacts];
            });
           
        }
    } else {
        [self uploadContactsToNodeWithContacts:contacts];
    }
    
}

/// 同步本地通讯录到节点
/// @param contacts 本地通讯录
- (void) uploadContactsToNodeWithContacts:(NSMutableArray *) contacts
{
    NSError *error;
    NSData *contactData =[CNContactVCardSerialization dataWithContacts:contacts error:&error];
    
    // 生成32位对称密钥
    NSString *msgKey = [SystemUtil get32AESKey];
    NSData *symmetData =[msgKey dataUsingEncoding:NSUTF8StringEncoding];
    NSString *symmetKey = [symmetData base64EncodedString];
    // 自己公钥加密对称密钥
    NSString *srcKey =[LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:[EntryModel getShareObject].publicKey];
    
    NSData *msgKeyData =[[msgKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
    contactData = aesEncryptData(contactData,msgKeyData);
    self.nodeContactData = contactData;
    NSInteger fid = [NSDate getTimestampFromDate:[NSDate date]];
    NSString *finfo = [NSString stringWithFormat:@"%ld",contacts.count];
    NSString *fileName = [NSString stringWithFormat:@"%ld.vcf",fid];
    SocketDataUtil *dataUtil = [[SocketDataUtil alloc] init];
    [dataUtil sendContactsToId:@"" fileName:fileName fileInfo:finfo fileData:contactData fileid:[NSString stringWithFormat:@"%ld",fid] fileType:9 srcKey:srcKey];
    [[SocketManageUtil getShareObject].socketArray addObject:dataUtil];
}

/// check 通讯录权限
#pragma mark 请求通讯录权限
- (void)requestContactAuthorAfterSystemVersion9{
    
    if (!_isPermissionContacts) {
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        if (status == CNAuthorizationStatusNotDetermined) {
            CNContactStore *store = [[CNContactStore alloc] init];
            @weakify_self
            [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError*  _Nullable error) {
                if (error) {
                    NSLog(@"授权失败");
                    [weakSelf showAlertViewAboutNotAuthorAccessContact];
                }else {
                    NSLog(@"成功授权");
                    weakSelf.isPermissionContacts = YES;
                }
            }];
        }
        else if(status == CNAuthorizationStatusRestricted)
        {
            NSLog(@"用户拒绝");
            [self showAlertViewAboutNotAuthorAccessContact];
        }
        else if (status == CNAuthorizationStatusDenied)
        {
            NSLog(@"用户拒绝");
            [self showAlertViewAboutNotAuthorAccessContact];
        }
        else if (status == CNAuthorizationStatusAuthorized)//已经授权
        {
            //有通讯录权限-- 进行下一步操作
            //[self exportContactVCF];
        }
    }
}

/// check 通讯录权限 提示
- (void)showAlertViewAboutNotAuthorAccessContact{
    
    UIAlertController *alertController = [UIAlertController
        alertControllerWithTitle:@"Please authorize address book privileges"
        message:@"Please allow Confidant to access your address book in the iPhone's \" Settings - privacy - contacts \" option"
        preferredStyle: UIAlertControllerStyleAlert];

    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:OKAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


/// 恢复通讯录
/// @param tag 1:更新 2:替换
- (void) importContactsVCFWithTag:(NSInteger) tag
{
    [self.view showHudInView:self.view hint:@"Recover..."];
    @weakify_self
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *fileName = [[UserModel getUserModel].userSn stringByAppendingString:@".vcf"];
        NSString *downloadFilePath = [SystemUtil getTempDeFilePath:fileName];
        
       __block  NSMutableArray *localArray = [NSMutableArray array];
        
        if (tag == 1) {
            if (weakSelf.localContactCount > 0) {
                CNContactStore*store = [[CNContactStore alloc]init];
                NSError*fetchError;
                CNContactFetchRequest*request = [[CNContactFetchRequest alloc]initWithKeysToFetch:@[[CNContactVCardSerialization descriptorForRequiredKeys],[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName]]];
                [store enumerateContactsWithFetchRequest:request error:&fetchError usingBlock:^(CNContact*contact,BOOL*stop) {
                    [localArray addObject:contact];
                }];
            }
        }
        
        
           
        if (![SystemUtil filePathisExist:downloadFilePath]) {
            
            [RequestService downFileWithBaseURLStr:self.nodeContactPath filePath:downloadFilePath progressBlock:^(CGFloat progress) {
                
            } success:^(NSURLSessionDownloadTask *dataTask, NSString *filePath) {
            
                NSData *fileData = [NSData dataWithContentsOfFile:filePath];
                [weakSelf deFileWithFileData:fileData withUploadNode:NO withDelContactTag:tag withLocalContacts:localArray];
                
            } failure:^(NSURLSessionDownloadTask *dataTask, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SystemUtil removeDocmentFilePath:downloadFilePath];
                    [weakSelf.view hideHud];
                    [weakSelf.view showHint:@"File download failed."];
                });
                
            }];
            
        } else {
 
            NSData *contactData = [NSData dataWithContentsOfFile:downloadFilePath];
            [weakSelf deFileWithFileData:contactData withUploadNode:NO withDelContactTag:tag withLocalContacts:localArray];
            /*
            NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
               NSString *plistPath = [paths objectAtIndex:0];
               NSString *filePath =[plistPath stringByAppendingPathComponent:@"contacts.vcf"];
            NSString *contactString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            NSData *contactData = [contactString dataUsingEncoding:NSUTF8StringEncoding];
            
            // 删除原有通讯录
            [weakSelf delOriginContacts];
            
            // 恢复到本地通讯录
            NSArray *contactArray = [CNContactVCardSerialization contactsWithData:contactData error:nil];
            if (contactArray && contactArray.count > 0) {
                CNContactStore*store = [[CNContactStore alloc]init];
                NSInteger finshCount = 0;
                if (tag == 1) {
                    finshCount = weakSelf.localContactCount;
                }
                for (CNContact *conact in  contactArray) {
                    //    实例化一个CNSaveRequest
                    CNSaveRequest * saveRequest = [[CNSaveRequest alloc]init];
                    [saveRequest addContact:[conact mutableCopy] toContainerWithIdentifier:nil];
                    [store executeSaveRequest:saveRequest error:nil];
                    finshCount++;
                    @weakify_self
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.lblLocalCount.text = [NSString stringWithFormat:@"%ld",finshCount];
                    });
                }
                @weakify_self
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.view hideHud];
                    [weakSelf.view showHint:@"Recover success."];
                    [[NSNotificationCenter defaultCenter] postNotificationName:Update_Loacl_Contact_Count_Noti object:nil];
                });
            }
             */
        }
    });
}

/// 删除原通讯录
- (void) delOriginContacts
{
    if (_localContactCount > 0) {
        CNContactStore*store = [[CNContactStore alloc]init];
        NSError*fetchError;
        CNContactFetchRequest*request = [[CNContactFetchRequest alloc]initWithKeysToFetch:@[[CNContactVCardSerialization descriptorForRequiredKeys],[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName]]];
        __block NSInteger finshCount = _localContactCount;
        @weakify_self
        [store enumerateContactsWithFetchRequest:request error:&fetchError usingBlock:^(CNContact*contact,BOOL*stop) {
           
            CNSaveRequest * saveRequest = [[CNSaveRequest alloc]init];
            [saveRequest deleteContact:[contact mutableCopy]];
            NSError *error;
            [store executeSaveRequest:saveRequest error:&error];
           
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    finshCount--;
                }
                weakSelf.lblLocalCount.text = [NSString stringWithFormat:@"%ld",finshCount];
            });
            
        }];
    }
    
}

/// 解密文件  备份 或 恢复·
/// @param fileData 文件
/// @param isUpload 是不是上传
/// @param tag 替换或更新
/// @param localContacts 本地通讯录数组
- (void) deFileWithFileData:(NSData *) fileData withUploadNode:(BOOL) isUpload withDelContactTag:(NSInteger) tag withLocalContacts:(NSMutableArray *) localContacts
{
    
    
   
    NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:self.nodeContactKey];
       if (datakey && datakey.length>0) {
           datakey  = [[[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding] substringToIndex:16];
           if (datakey && ![datakey isEmptyString]) {
              NSData *deFileData = aesDecryptData(fileData, [datakey dataUsingEncoding:NSUTF8StringEncoding]);
               if (deFileData) {
                   if (isUpload) { // 是上传
                       
                       NSArray *contactArray = [CNContactVCardSerialization contactsWithData:deFileData error:nil];
                       NSMutableArray *tempArray = [NSMutableArray array];
                       
                       for (CNContact *conact in  contactArray) {
                           BOOL isExit = NO;
                           for (CNContact *localConact in  localContacts) {
                               if ([conact.givenName?:@"" isEqualToString:localConact.givenName?:@""] && [conact.familyName?:@"" isEqualToString:localConact.familyName?:@""]) {
                                   
                                   NSArray *phoneNumbers1 = conact.phoneNumbers?:@[];
                                   NSArray *phoneNumbers2 = localConact.phoneNumbers?:@[];
                                   if (phoneNumbers1.count == 0 && phoneNumbers2.count == 0) {
                                       isExit = YES;
                                       break;
                                   } else if (phoneNumbers1.count >0 && phoneNumbers2.count >0){
                                       CNLabeledValue *v1 = [phoneNumbers1 objectAtIndex:0];
                                       CNLabeledValue *v2 = [phoneNumbers2 objectAtIndex:0];
                                       CNPhoneNumber *phoneNumber1 = v1.value;
                                       CNPhoneNumber *phoneNumber2 = v2.value;
                                       if ([phoneNumber1.stringValue?:@"" isEqualToString:phoneNumber2.stringValue?:@""]) {
                                           isExit = YES;
                                           break;
                                       }
                                   }
                               }
                           }
                           if (!isExit) {
                               [tempArray addObject:conact];
                           }
                       }
                       
                       if (tempArray.count > 0) {
                           [localContacts addObjectsFromArray:tempArray];
                       }
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self uploadContactsToNodeWithContacts:localContacts];
                       });
                       
                       [FIRAnalytics logEventWithName:kFIREventSelectContent
                       parameters:@{
                                    kFIRParameterItemID:FIR_CONTACTS_SYNC,
                                    kFIRParameterItemName:FIR_CONTACTS_SYNC,
                                    kFIRParameterContentType:FIR_CONTACTS_SYNC
                                    }];
                       
                   } else {
                       if (tag == 2) {
                           // 删除原有通讯录
                           [self delOriginContacts];
                       }
                       
                       [FIRAnalytics logEventWithName:kFIREventSelectContent
                       parameters:@{
                                    kFIRParameterItemID:FIR_CONTACTS_RECOVER,
                                    kFIRParameterItemName:FIR_CONTACTS_RECOVER,
                                    kFIRParameterContentType:FIR_CONTACTS_RECOVER
                                    }];
                       
                       // 恢复到本地通讯录
                       NSArray *nodeContactArray = [CNContactVCardSerialization contactsWithData:deFileData error:nil]?:@[];
                       NSMutableArray *updateContactArray = [NSMutableArray array];
                       if (tag == 1) { // 更新本地
                           for (CNContact *conact in  nodeContactArray) {
                               BOOL isExit = NO;
                               for (CNContact *localConact in  localContacts) {
                                   if ([conact.givenName?:@"" isEqualToString:localConact.givenName?:@""] && [conact.familyName?:@"" isEqualToString:localConact.familyName?:@""]) {
                                       
                                       NSArray *phoneNumbers1 = conact.phoneNumbers?:@[];
                                       NSArray *phoneNumbers2 = localConact.phoneNumbers?:@[];
                                       if (phoneNumbers1.count == 0 && phoneNumbers2.count == 0) {
                                           isExit = YES;
                                           break;
                                       } else if (phoneNumbers1.count >0 && phoneNumbers2.count >0){
                                           CNLabeledValue *v1 = [phoneNumbers1 objectAtIndex:0];
                                           CNLabeledValue *v2 = [phoneNumbers2 objectAtIndex:0];
                                           CNPhoneNumber *phoneNumber1 = v1.value;
                                           CNPhoneNumber *phoneNumber2 = v2.value;
                                           if ([phoneNumber1.stringValue?:@"" isEqualToString:phoneNumber2.stringValue?:@""]) {
                                               isExit = YES;
                                               break;
                                           }
                                       }
                                   }
                               }
                               if (!isExit) {
                                   [updateContactArray addObject:conact];
                               }
                           }
                       } else {
                           [updateContactArray addObjectsFromArray:nodeContactArray];
                       }
                       
                       
                       if (updateContactArray && updateContactArray.count > 0) {
                           CNContactStore*store = [[CNContactStore alloc]init];
                          __block NSInteger finshCount = 0;
                           if (tag == 1) {
                               finshCount = _localContactCount;
                           }
                           NSError *error;
                           for (CNContact *conact in  updateContactArray) {
                               //    实例化一个CNSaveRequest
                               CNSaveRequest * saveRequest = [[CNSaveRequest alloc]init];
                               [saveRequest addContact:[conact mutableCopy] toContainerWithIdentifier:nil];
                               [store executeSaveRequest:saveRequest error:&error];
                              
                               @weakify_self
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   if (!error) {
                                        finshCount++;
                                        weakSelf.lblLocalCount.text = [NSString stringWithFormat:@"%ld",finshCount];
                                   }
                               });
                           }
                           @weakify_self
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [weakSelf.view hideHud];
                               [weakSelf.view showHint:@"Recover success."];
                               [[NSNotificationCenter defaultCenter] postNotificationName:Update_Loacl_Contact_Count_Noti object:nil];
                           });
                       } else {
                          
                            @weakify_self
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [weakSelf.view hideHud];
                               if (tag == 1) {
                                   [weakSelf.view showHint:@"Recover success."];
                               } else {
                                   [weakSelf.view showHint:@"Recover failure."];
                               }
                           });
                       }
                   }
               } else {
                    @weakify_self
                   dispatch_async(dispatch_get_main_queue(), ^{
                       [weakSelf.view hideHud];
                       [weakSelf.view showHint:@"Decryption failure."];
                   });
               }
           }
       } else {
           @weakify_self
           dispatch_async(dispatch_get_main_queue(), ^{
               [weakSelf.view hideHud];
               [weakSelf.view showHint:@"Decryption failure."];
           });
       }
}


#pragma mark---------------请求通知
- (void) uploadContactsSuccessNoti:(NSNotification *) noti
{
    NSDictionary *resutDic = noti.object;
    if ([resutDic[@"Depens"] integerValue] == 4) { // 通讯录
        if ([resutDic[@"RetCode"] integerValue] == 0) {
            
            self.nodeContactPath = resutDic[@"FilePath"];
            self.nodeContactKey = resutDic[@"FKey"];
            self.nodeContactCount = resutDic[@"FInfo"];
            
            // 将节点备份文件写入本地
            NSString *fileName = [[UserModel getUserModel].userSn stringByAppendingString:@".vcf"];
            NSString *downloadFilePath = [SystemUtil getTempDeFilePath:fileName];
            if ([SystemUtil filePathisExist:downloadFilePath]) {
                [SystemUtil removeDocmentFilePath:downloadFilePath];
            }
            [self.nodeContactData writeToFile:downloadFilePath atomically:YES];
            // 更新首页ui通知
            [[NSNotificationCenter defaultCenter] postNotificationName:Update_Loacl_Contact_Count_Noti object:@[self.nodeContactPath,self.nodeContactKey,self.nodeContactCount]];
           
            __block NSInteger uploadCount = 0;
            __block NSInteger count = [self.nodeContactCount integerValue];
            _lblNodeCount.text = @"0";
            // 假动画显示
            @weakify_self
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                while (uploadCount < count) {
                    uploadCount += 20;
                    if (uploadCount >= count) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.view hideHud];
                            weakSelf.lblNodeCount.text = [NSString stringWithFormat:@"%ld",count];
                            [weakSelf.view showHint:@"Sync success."];
                        });
                       
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.lblNodeCount.text = [NSString stringWithFormat:@"%ld",uploadCount];
                        });
                    }
                    [NSThread sleepForTimeInterval:0.1];
                }
                
                
            });
            
        } else {
            [self.view hideHud];
            [self.view showHint:@"Sync failure."];
        }
    }
    
}
- (void) contactsUploadFileDataNoti:(NSNotification *) noti
{
    PNFileUploadModel *fileM = noti.object;
    if (fileM.retCode !=0) { // 文件上传成功后，告知节点
        [self.view hideHud];
        [self.view showHint:@"Sync failure."];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
