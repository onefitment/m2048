//
//  M2ViewController.m
//  m2048
//
//  Created by Danqing on 3/16/14.
//  Copyright (c) 2014 Danqing. All rights reserved.
//

#import "M2ViewController.h"
#import "M2SettingsViewController.h"
#import <AppLovinSDK/AppLovinSDK.h> // If using SDK as first-class framework


#import "M2Scene.h"
#import "M2GameManager.h"
#import "M2ScoreView.h"
#import "M2Overlay.h"
#import "M2GridView.h"
#import "Macros.h"
#import "M2GameCenterManager.h"
#import "M2HomeViewController.h"

NSString *const bestScoreOf2 = @"BestScoreOf2";
NSString *const bestScoreOf3 = @"BestScoreOf3";
NSString *const bestScoreOf4 = @"BestScoreOf5";

@interface M2ViewController () <ALAdRewardDelegate,ALAdDisplayDelegate>
@property (nonatomic, strong) ALAdView *adView ;
@property (nonatomic, strong) M2GameCenterManager *gameCenterManager;
@end

@implementation M2ViewController {
    IBOutlet UIButton *_restartButton;
    IBOutlet UIButton *_settingsButton;
    IBOutlet UILabel *_targetScore;
    IBOutlet UILabel *_subtitle;
    IBOutlet M2ScoreView *_scoreView;
    IBOutlet M2ScoreView *_bestView;
    
    M2Scene *_scene;
    
    IBOutlet M2Overlay *_overlay;
    IBOutlet UIImageView *_overlayBackground;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateState];
    
    _bestView.score.text = [NSString stringWithFormat:@"%ld", (long)[Settings integerForKey:@"Best Score"]];
    
    _restartButton.layer.cornerRadius = [GSTATE cornerRadius];
    _restartButton.layer.masksToBounds = YES;
    
    _settingsButton.layer.cornerRadius = [GSTATE cornerRadius];
    _settingsButton.layer.masksToBounds = YES;
    
    _overlay.hidden = YES;
    _overlayBackground.hidden = YES;
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    
    // Create and configure the scene.
    M2Scene * scene = [M2Scene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    [self updateScore:0];
    [scene startNewGame];
    
    _scene = scene;
    _scene.controller = self;
    //初始化广告
    [ALIncentivizedInterstitialAd shared].adDisplayDelegate = self;
    [ALIncentivizedInterstitialAd preloadAndNotify:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Load an ad into the ad view
//    [self.adView loadNextAd];
//    adView.backgroundColor = [UIColor orangeColor];
    
    // Add it to the view
    //验证用户是否登录了
    [self.gameCenterManager authenticateLocalUser:self];
    self.gameCenterManager.adDelayCount --;
    [self showAdVideo:0];
    
}


- (void)updateState
{
    [_scoreView updateAppearance];
    [_bestView updateAppearance];
    
    _restartButton.backgroundColor = [GSTATE buttonColor];
    _restartButton.titleLabel.font = [UIFont fontWithName:[GSTATE boldFontName] size:14];
    
    _settingsButton.backgroundColor = [GSTATE buttonColor];
    _settingsButton.titleLabel.font = [UIFont fontWithName:[GSTATE boldFontName] size:14];
    
    _targetScore.textColor = [GSTATE buttonColor];
    
    long target = [GSTATE valueForLevel:GSTATE.winningLevel];
    
    if (target > 100000) {
        _targetScore.font = [UIFont fontWithName:[GSTATE boldFontName] size:34];
    } else if (target < 10000) {
        _targetScore.font = [UIFont fontWithName:[GSTATE boldFontName] size:42];
    } else {
        _targetScore.font = [UIFont fontWithName:[GSTATE boldFontName] size:40];
    }
    
    _targetScore.text = [NSString stringWithFormat:@"%ld", target];
    
    _subtitle.textColor = [GSTATE buttonColor];
    _subtitle.font = [UIFont fontWithName:[GSTATE regularFontName] size:14];
    _subtitle.text = [NSString stringWithFormat:@"达到并超过这个分数: %ld!", target];
    
    _overlay.message.font = [UIFont fontWithName:[GSTATE boldFontName] size:36];
    _overlay.keepPlaying.titleLabel.font = [UIFont fontWithName:[GSTATE boldFontName] size:17];
    _overlay.restartGame.titleLabel.font = [UIFont fontWithName:[GSTATE boldFontName] size:17];
    
    _overlay.message.textColor = [GSTATE buttonColor];
    [_overlay.keepPlaying setTitleColor:[GSTATE buttonColor] forState:UIControlStateNormal];
    [_overlay.restartGame setTitleColor:[GSTATE buttonColor] forState:UIControlStateNormal];
}


- (void)updateScore:(NSInteger)score
{
    _scoreView.score.text = [NSString stringWithFormat:@"%ld", (long)score];
    NSInteger type = [Settings integerForKey:@"Game Type"];
    if (type == 0) {
        if ([Settings integerForKey:bestScoreOf2] < score) {
            [self recordScore:score withKey:bestScoreOf2 andType:type];
        }
    } else if(type == 1) {
        if ([Settings integerForKey:bestScoreOf3] < score) {
            [self recordScore:score withKey:bestScoreOf3 andType:type];
        }
    } else if(type == 2){
        if ([Settings integerForKey:bestScoreOf3] < score) {
            [self recordScore:score withKey:bestScoreOf3 andType:type];
        }
    }
    if ([Settings integerForKey:@"Best Score"] < score) {
        [Settings setInteger:score forKey:@"Best Score"];
        _bestView.score.text = [NSString stringWithFormat:@"%ld", (long)score];
        [self.gameCenterManager reportScore:score andType:3];
    }
    
}

- (void)recordScore:(int64_t)score withKey:(NSString *)key andType:(NSInteger)type{
    [Settings setInteger:score forKey:key];
    [self.gameCenterManager reportScore:score andType:type];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self.gameCenterManager showGameCenterWithVC:self];
    // Pause Sprite Kit. Otherwise the dismissal of the modal view would lag.
    ((SKView *)self.view).paused = YES;
}


- (IBAction)restart:(id)sender
{
    [self hideOverlay];
    [self updateScore:0];
    [_scene startNewGame];
    [self showAdVideo:1];
}


- (IBAction)keepPlaying:(id)sender
{
    [self hideOverlay];
}


- (IBAction)done:(UIStoryboardSegue *)segue
{
    ((SKView *)self.view).paused = NO;
    if (GSTATE.needRefresh) {
        [GSTATE loadGlobalState];
        [self updateState];
        [self updateScore:0];
        [_scene startNewGame];
    }
}


- (void)endGame:(BOOL)won
{
    _overlay.hidden = NO;
    _overlay.alpha = 0;
    _overlayBackground.hidden = NO;
    _overlayBackground.alpha = 0;
    
    if (!won) {
        _overlay.keepPlaying.hidden = YES;
        _overlay.message.text = @"游戏结束！";
    } else {
        _overlay.keepPlaying.hidden = NO;
        _overlay.message.text = @"你获胜了!";
    }
    
    // Fake the overlay background as a mask on the board.
    _overlayBackground.image = [M2GridView gridImageWithOverlay];
    
    // Center the overlay in the board.
    CGFloat verticalOffset = [[UIScreen mainScreen] bounds].size.height - GSTATE.verticalOffset;
    NSInteger side = GSTATE.dimension * (GSTATE.tileSize + GSTATE.borderWidth) + GSTATE.borderWidth;
    _overlay.center = CGPointMake(GSTATE.horizontalOffset + side / 2, verticalOffset - side / 2);
    
    [UIView animateWithDuration:0.5 delay:1.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _overlay.alpha = 1;
        _overlayBackground.alpha = 1;
    } completion:^(BOOL finished) {
        // Freeze the current game.
        ((SKView *)self.view).paused = YES;
    }];
    //游戏结束，播放广告
    [self showAdVideo:1];
}


#pragma mark -- 进入首页
- (IBAction)mainBtnClick:(id)sender {
    M2HomeViewController *homeVC = [[M2HomeViewController alloc] init];
    [self.navigationController pushViewController:homeVC animated:YES];
}

#pragma mark -- 显示广告视频
- (void)showAdVideo:(NSInteger)type {
    if (self.gameCenterManager.adDelayCount || !type) {
        self.gameCenterManager.adDelayCount = 3;
        return;
    }
    if([ALIncentivizedInterstitialAd isReadyForDisplay]) {
        [ALIncentivizedInterstitialAd show];
        [ALIncentivizedInterstitialAd showAndNotify:self];
    }
}

#pragma mark ALIncentivizedInterstitialAd delegate
//拒绝播放广告
- (void)rewardValidationRequestForAd:(ALAd *)ad wasRejectedWithResponse:(NSDictionary *)response {
    
}

//成功播放广告
- (void)rewardValidationRequestForAd:(ALAd *)ad didSucceedWithResponse:(NSDictionary *)response {
    
}

- (void)rewardValidationRequestForAd:(ALAd *)ad didExceedQuotaWithResponse:(NSDictionary *)response {
    
}

- (void)rewardValidationRequestForAd:(ALAd *)ad didFailWithError:(NSInteger)responseCode {
    
}

// ALAdDisplayDelegate methods
- (void)ad:(ALAd *)ad wasClickedIn:(UIView *)view {
    
}
- (void)ad:(ALAd *)ad wasDisplayedIn:(UIView *)view {
    
}
- (void)ad:(ALAd *)ad wasHiddenIn:(UIView *)view {
    // The user has closed the ad.  We must preload the next rewarded video.
    [ALIncentivizedInterstitialAd preloadAndNotify:nil];
}
- (void)hideOverlay
{
    ((SKView *)self.view).paused = NO;
    if (!_overlay.hidden) {
        [UIView animateWithDuration:0.5 animations:^{
            _overlay.alpha = 0;
            _overlayBackground.alpha = 0;
        } completion:^(BOOL finished) {
            _overlay.hidden = YES;
            _overlayBackground.hidden = YES;
        }];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (M2GameCenterManager *)gameCenterManager {
    if (!_gameCenterManager) {
        _gameCenterManager = [M2GameCenterManager share];
    }
    return _gameCenterManager;
}

- (ALAdView *)adView {
    if (!_adView) {
        _adView = [[ALAdView alloc] initWithFrame: CGRectMake(0,Main_Screen_Height - 50 , Main_Screen_Width, 50.0f) size: [ALAdSize sizeBanner] sdk: [ALSdk shared]];
        [self.view addSubview:_adView];
    }
    return _adView;
}


@end
