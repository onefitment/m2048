//
//  M2GameCenterManager.m
//  m2048
//
//  Created by larou on 2017/6/15.
//  Copyright © 2017年 Danqing. All rights reserved.
//

#import "M2GameCenterManager.h"
#import <GameKit/GameKit.h>

#define kIdentifierScore  @"2_2"
#define kIdentifierScore  @"2_2"
#define kIdentifierScore  @"2_2"

@interface M2GameCenterManager ()<GKGameCenterControllerDelegate>
@property (nonatomic, strong) GKLocalPlayer *localPlayer;

@end

@implementation M2GameCenterManager

//是否支持GameCenter
- (BOOL) isGameCenterAvailable
{
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

//身份验证
- (void)authenticateLocalUser:(UIViewController *)mainVC{
    self.localPlayer = [GKLocalPlayer localPlayer];
    
    self.localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            [mainVC presentViewController:viewController animated:YES completion:nil];
        }
        else{
            if ([GKLocalPlayer localPlayer].authenticated) {
                // Get the default leaderboard identifier.
                
                [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
                    
                    if (error != nil) {
                        NSLog(@"%@", [error localizedDescription]);
                    }
                    else{
                        
                    }
                }];
            }
            
            else{
                
            }
        }
    };
}

//用户变更检测
- (void)registerFoeAuthenticationNotification{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(authenticationChanged) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
}

- (void)authenticationChanged{
    if([GKLocalPlayer localPlayer].isAuthenticated){
        
    }else{
        
    }
    
}

//上传分数
- (void)reportScore: (int64_t) score andType:(M2GameType)gameType{
    GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:kIdentifierScore ];
    scoreReporter.value = score;
    if (gameType == M2GameTypePowerOf2) {
        
    } else if (gameType == M2GameTypePowerOf3) {
        
    } else {
        
    }
    
    [GKScore reportScores:@[scoreReporter] withCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSData *saveSocreData = [NSKeyedArchiver archivedDataWithRootObject:scoreReporter];
            [self storeScoreForLater:saveSocreData];
        }
    }];
}


- (void)storeScoreForLater:(NSData *)scoreData{
    NSMutableArray *savedScoresArray = [[NSMutableArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"savedScores"]];
    
    [savedScoresArray addObject:scoreData];
    [[NSUserDefaults standardUserDefaults] setObject:savedScoresArray forKey:@"savedScores"];
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    
}

@end
