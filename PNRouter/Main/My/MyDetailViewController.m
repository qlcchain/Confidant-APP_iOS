//
//  MyDetailViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/10.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "MyDetailViewController.h"
#import "MyCell.h"
#import "PersonCodeViewController.h"
#import "UserModel.h"
#import "UIImage+Resize.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "EditTextViewController.h"
#import "UserConfig.h"
#import "PNRouter-Swift.h"

@interface MyDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    UIImage *_selectImage;
}
@property (nonatomic , strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@end

@implementation MyDetailViewController


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [_tableV reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _tableV.delegate = self;
    _tableV.dataSource = self;
    _tableV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableV registerNib:[UINib nibWithNibName:MyCellReuse bundle:nil] forCellReuseIdentifier:MyCellReuse];
}

#pragma mark - Action
- (IBAction)backBtnAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}

#pragma mark - Operation
- (void)showPickPhoto {
    @weakify_self
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *alert1 = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf selectImage:YES];
    }];
    [alertC addAction:alert1];
    UIAlertAction *alert2 = [UIAlertAction actionWithTitle:@"Select From Photos" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf selectImage:NO];
    }];
    [alertC addAction:alert2];
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertC addAction:alertCancel];
    [self presentViewController:alertC animated:YES completion:nil];
}

#pragma mark - tableviewDataSourceDelegate
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return MyCellReuse_Height;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MyCell *cell = [tableView dequeueReusableCellWithIdentifier:MyCellReuse];
    cell.lblContent.text = self.dataArray[indexPath.row];
    if (indexPath.row == 0 || indexPath.row == 2) {
        cell.lblSubContent.hidden = YES;
        cell.subBtn.hidden = NO;
        if (indexPath.row == 0) {
            if ([UserModel getUserModel].headBaseStr) {
                [cell.subBtn setImage:[UIImage imageWithData:[UserModel getUserModel].headBaseStr.base64DecodedData] forState:UIControlStateNormal];
                [cell.subBtn setTitle:@"" forState:UIControlStateNormal];
            } else {
                [cell.subBtn setBackgroundImage:[UIImage imageNamed:@"detailHead"] forState:UIControlStateNormal];
                [cell.subBtn setTitle:[StringUtil getUserNameFirstWithName:[UserModel getUserModel].username] forState:UIControlStateNormal];
            }
            
        } else {
             [cell.subBtn setImage:[UIImage imageNamed:@"icon_code"] forState:UIControlStateNormal];
        }
    } else {
        UserModel *userModel = [UserModel getUserModel];
        cell.lblSubContent.hidden = NO;
        cell.subBtn.hidden = YES;
        if (indexPath.row == 1) {
            cell.lblSubContent.text = userModel.username;
        } else if (indexPath.row ==3){ // 公司
            cell.lblSubContent.text = userModel.commpany?:@"";
        } else if (indexPath.row ==4){ // 职业
            cell.lblSubContent.text = userModel.position?:@"";
        }  else if (indexPath.row ==5){ // 地区
            cell.lblSubContent.text =userModel.location?:@"";
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 2) {
        PersonCodeViewController *vc = [[PersonCodeViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.row == 0) {
        [self showPickPhoto];
    } else {
        EditType type = EditName;
        if (indexPath.row ==3){ // 公司
            type = EditCompany;
        } else if (indexPath.row ==4){ // 职业
            type = EditPosition;
        }  else if (indexPath.row ==5){ // 地区
            type = EditLocation;
        }
        EditTextViewController *vc = [[EditTextViewController alloc] initWithType:type];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark 调用相机
//调用系统相册
- (void)selectImage:(BOOL)isCamera {
    //调用系统相册的类
    UIImagePickerController *pickerController = [[UIImagePickerController alloc]init];
    //    更改titieview的字体颜色
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSForegroundColorAttributeName] = MAIN_PURPLE_COLOR;
    [pickerController.navigationBar setTitleTextAttributes:attrs];
    pickerController.navigationBar.translucent = NO;
    pickerController.navigationBar.barTintColor = MAIN_WHITE_COLOR;
    //设置选取的照片是否可编辑
    pickerController.allowsEditing = YES;
    //设置相册呈现的样式
    if (isCamera) {
        pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    //UIImagePickerControllerSourceTypeSavedPhotosAlbum;//图片分组列表样式
    //照片的选取样式还有以下两种
    // UIImagePickerControllerSourceTypePhotoLibrary,直接全部呈现系统相册
    //UIImagePickerControllerSourceTypeCamera//调取摄像头
    //选择完成图片或者点击取消按钮都是通过代理来操作我们所需要的逻辑过程
    pickerController.delegate = self;
    //使用模态呈现相册
    //[self showDetailViewController:pickerController sender:nil];
    [self.navigationController presentViewController:pickerController animated:YES completion:nil];
    
}

#pragma UIImagePickerController delegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    //    UIImagePickerControllerEditedImage//编辑过的图片
    //    UIImagePickerControllerOriginalImage//原图
    UIImage *resultImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    if (resultImage) {
        resultImage = [resultImage resizeImage:resultImage];
        UserModel *model = [UserModel getUserModel];
        model.headBaseStr = UIImagePNGRepresentation(resultImage).base64EncodedString;
        [model saveUserModeToKeyChain];
        _selectImage = resultImage;
        [_tableV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [[NSNotificationCenter defaultCenter] postNotificationName:USER_HEAD_CHANGE_NOTI object:nil];
    }
    
    //    [_headImageView sd_setImageWithURL:[NSURL URLWithString:[UserManage getHeadUrl]] placeholderImage:nil];
    
    //    [_topHeadImgView sd_setImageWithURL:[NSURL URLWithString:[UserManage getHeadUrl]] placeholderImage:nil];
    
    //    _topHeadImgView.image = [_topHeadImgView hyb_setImage:resultImage size:CGSizeMake(100, 100) cornerRadius:50 onCliped:nil];
    //    _topHeadImgView.hyb_borderColor = [UIColor whiteColor];
    //    _topHeadImgView.hyb_borderWidth = 5.0f;
    //使用模态返回到软件界面
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - layz
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithObjects:@"Profile Photo",@"Name",@"My QR Code",@"Company",@"Occupation",@"Region", nil];
    }
    return _dataArray;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
