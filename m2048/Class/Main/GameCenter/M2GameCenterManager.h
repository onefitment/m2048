//
//  M2GameCenterManager.h
//  m2048
//
//  Created by larou on 2017/6/15.
//  Copyright © 2017年 Danqing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface M2GameCenterManager : NSObject
//身份验证
- (void)authenticateLocalUser:(UIViewController *)mainVC;
//上传分数
- (void)reportScore: (int64_t) score andType:(M2GameType)gameType;

- (void)showGameCenterWithVC:(UIViewController *)vc;

@end
