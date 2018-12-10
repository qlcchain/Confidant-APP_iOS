//
//  UITool.h
//  Utility
//
//  Created by chdo on 2017/12/8.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <SDWebImage/UIImageView+WebCache.h>

// 系统版本号
double CDDeviceSystemVersion(void);

CGSize CDScreenSize(void);

/**
 颜色
 */
UIColor *CDHexColor(int hexColor); // 16位颜色
UIColor *CDRadomColor(void); //随机色
//UIColor *RGB(CGFloat A, CGFloat B, CGFloat C);


/**
 尺寸
 */
CGFloat cd_NaviH(void);
CGFloat cd_ScreenW(void);
CGFloat cd_ScreenH(void);
CGFloat cd_StatusH(void);

//
NSInteger CDFileSizeByFileUrl(NSURL *filePath);
NSInteger CDFileSizeByFilePath(NSString *filePath);

@interface UIView (CD)

@property (nonatomic, readonly) UIViewController *cd_viewController;

@property (nonatomic) CGFloat cd_left;        ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat cd_top;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat cd_right;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat cd_bottom;      ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat cd_width;       ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat cd_height;      ///< Shortcut for frame.size.height.

@end



#define WeakObj(o) __weak typeof(o) o##Weak = o;
#define StrongObj(o) __weak typeof(o) o##Strong = o;


#define RGB(A, B, C)    [UIColor colorWithRed:A/255.0 green:B/255.0 blue:C/255.0 alpha:1.0]
#define RGBA(A, B, C, alp)    [UIColor colorWithRed:A/255.0 green:B/255.0 blue:C/255.0 alpha: alp]
