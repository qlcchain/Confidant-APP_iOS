//
//  CDChatInPutMacro.h
//  Pods
//
//  Created by chdo on 2017/12/12.
//

#ifndef CTInPutMacro_h
#define CTInPutMacro_h

// 其他
#define HexColor(hexColor) [UIColor colorWithRed:((float)((hexColor & 0xFF0000) >> 16))/255.0 green:((float)((hexColor & 0xFF00) >> 8))/255.0 blue:((float)(hexColor & 0xFF))/255.0 alpha:1]
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#endif /* CTInPutMacro_h */
