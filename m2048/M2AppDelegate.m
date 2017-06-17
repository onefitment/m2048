//
//  M2AppDelegate.m
//  m2048
//
//  Created by Danqing on 3/16/14.
//  Copyright (c) 2014 Danqing. All rights reserved.
//

#import "M2AppDelegate.h"
#import <AppLovinSDK/AppLovinSDK.h>
#import <BmobSDK/Bmob.h>
#import <AVFoundation/AVFoundation.h>
#import "introductoryPagesHelper.h"

#define bmobID @"e3f44447bee428928846ab5eb74eeb17"

@implementation M2AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Bmob registerWithAppKey:bmobID];
    NSError* error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    //引导页面加载
    [self setupIntroductoryPage];
    return YES;
}

#pragma mark 引导页
-(void)setupIntroductoryPage
{
    if (BBUserDefault.isNoFirstLaunch)
    {
        return;
    }
    BBUserDefault.isNoFirstLaunch=YES;
    NSArray *images=@[@"introductoryPage1",@"introductoryPage2",@"introductoryPage3",@"introductoryPage4"];
    [introductoryPagesHelper showIntroductoryPageView:images];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    [ALSdk initializeSdk];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    //MBAudioPlayer是我为播放器写的单例，这段就是当音乐还在播放状态的时候，给后台权限，不在播放状态的时候，收回后台权限
//    if ([MBAudioPlayer shareInstance].audioPlayer.state == STKAudioPlayerStatePlaying||[MBAudioPlayer shareInstance].audioPlayer.state == STKAudioPlayerStateBuffering||[MBAudioPlayer shareInstance].audioPlayer.state == STKAudioPlayerStatePaused ||[MBAudioPlayer shareInstance].audioPlayer.state == STKAudioPlayerStateStopped) {
//        //有音乐播放时，才给后台权限，不做流氓应用。
//        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//        [self becomeFirstResponder];
//        //开启定时器
//        [[MBAudioPlayer shareInstance] decideTimerWithType:MBAudioTimerStartBackground andBeginState:YES];
//        [[MBAudioPlayer shareInstance] configNowPlayingInfoCenter];
//    }
//    else
//    {
//        [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
//        [self resignFirstResponder];
//        //检测是都关闭定时器
//        [[MBAudioPlayer shareInstance] decideTimerWithType:MBAudioTimerStartBackground andBeginState:NO];
//    }
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
