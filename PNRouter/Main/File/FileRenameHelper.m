//
//  FileRenameHelper.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/6.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "FileRenameHelper.h"
#import "FileListModel.h"
#import "PNRouter-Swift.h"
#import "NSString+File.h"
#import "NSString+Trim.h"

@implementation FileRenameHelper

+ (void)showRenameViewWithModel:(FileListModel *)model vc:(PNBaseViewController *)vc {
    NSString *fileName = [Base58Util Base58DecodeWithCodeName:model.FileName]?:@"";
    NSString *title = @"Rename the File";
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    NSMutableAttributedString *titleAttr = [[NSMutableAttributedString alloc] initWithString:title];
    [titleAttr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:18] range:NSMakeRange(0, [[titleAttr string] length])];
    [titleAttr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x030303) range:NSMakeRange(0, [[titleAttr string] length])];
    [alertC setValue:titleAttr forKey:@"attributedTitle"];
    [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = fileName.stringByDeletingPathExtension;
    }];
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertCancel setValue:UIColorFromRGB(0x00152B) forKey:@"_titleTextColor"];
    [alertC addAction:alertCancel];
    UIAlertAction *alertConfirm = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textField = alertC.textFields.firstObject;
        
        NSString *aliasName = [NSString trimWhitespaceAndNewline:[NSString getNotNullValue:textField.text]];
        
        if ([aliasName isEmptyString]) {
            [AppD.window showHint:@"Please enter file name"];
            return;
        }
        NSString *rename = fileName.pathExtension?[aliasName stringByAppendingPathExtension:fileName.pathExtension]:aliasName;
        rename = [NSString getUploadFileNameOfCorrectLength:rename];
//        NSString *rename = [textField.text stringByAppendingString:[fileName stringByReplacingOccurrencesOfString:fileName.stringByDeletingPathExtension withString:@""]?:@""];
        [SendRequestUtil sendFileRenameWithMsgId:model.MsgId Filename:fileName Rename:rename showHud:YES];
    }];
    [alertConfirm setValue:UIColorFromRGB(0x00152B) forKey:@"_titleTextColor"];
    [alertC addAction:alertConfirm];
    [vc presentViewController:alertC animated:YES completion:^{
        UITextField *textField = alertC.textFields.firstObject;
        [textField becomeFirstResponder];
    }];
}

@end
