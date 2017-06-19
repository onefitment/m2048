//
//  M2GameCenterManager.m
//  m2048
//
//  Created by larou on 2017/6/15.
//  Copyright © 2017年 Danqing. All rights reserved.
//

#import "M2GameCenterManager.h"
#import <GameKit/GameKit.h>

#define kIdentifierScore2  @"2_2"
#define kIdentifierScore3  @"3_3_3"
#define kIdentifierScore5  @"2_3_5"
#define kIdentifierAllScore @"maxScore"

@interface M2GameCenterManager ()<GKGameCenterControllerDelegate>
@property (nonatomic, strong) GKLocalPlayer *localPlayer;

@end

@implementation M2GameCenterManager

+ (M2GameCenterManager *)share {
    static M2GameCenterManager* share = nil;
    static dispatch_once_t one;
    dispatch_once(&one, ^{
        share = [[M2GameCenterManager alloc] init];
        share.adDelayCount = 3;
    });
    return share;
}

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
        if ([[GKLocalPlayer localPlayer] isAuthenticated]) {
            NSLog(@"已授权");
        } else {
            if (viewController ) {
                [mainVC presentViewController:viewController animated:YES completion:nil];
            } else {
                
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
    GKScore *scoreReporter;
    if (gameType == M2GameTypePowerOf2) {
        scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:kIdentifierScore2];
    } else if (gameType == M2GameTypePowerOf3) {
        scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:kIdentifierScore3];
    } else if(gameType == M2GameTypeFibonacci){
        scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:kIdentifierScore5];
    } else {
        scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:kIdentifierAllScore];
    }
    scoreReporter.value = score;
    
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

- (void)showGameCenterWithVC:(UIViewController *)vc {
    GKGameCenterViewController *gameViewController = [[GKGameCenterViewController alloc] init];
    if (gameViewController) {
        if ([self.localPlayer isAuthenticated]) {
            gameViewController.view.backgroundColor = [[GSTATE backgroundColor] colorWithAlphaComponent:0.8];
            gameViewController.gameCenterDelegate = self;
            [gameViewController setLeaderboardTimeScope:GKLeaderboardTimeScopeAllTime];
            [gameViewController setLeaderboardIdentifier:kIdentifierAllScore];
            [vc presentViewController:gameViewController animated:YES completion:nil];
        }
    }
//    self.localPlayer = [GKLocalPlayer localPlayer];
//    __weak typeof(self) weakSelf = self;
//    self.localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
//        if ([[GKLocalPlayer localPlayer] isAuthenticated]) {
//            GKGameCenterViewController *gameViewController = [[GKGameCenterViewController alloc] init];
//            gameViewController.view.backgroundColor = [[GSTATE backgroundColor] colorWithAlphaComponent:0.8];
//            if (gameViewController) {
//                gameViewController.gameCenterDelegate = weakSelf;
//                [gameViewController setLeaderboardTimeScope:GKLeaderboardTimeScopeAllTime];
//                [gameViewController setLeaderboardIdentifier:kIdentifierAllScore];
//                [vc presentViewController:gameViewController animated:YES completion:nil];
//            }
//        } else {
//            if (viewController ) {
//                [vc presentViewController:viewController animated:YES completion:nil];
//            } else {
//                //登录没有被允许，请去设置中心设置gameCenter
//            }
//        }
//    };

}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];

}

@end
