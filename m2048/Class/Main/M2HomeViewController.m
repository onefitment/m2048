//
//  M2HomeViewController.m
//  m2048
//
//  Created by larou on 2017/6/16.
//  Copyright © 2017年 Danqing. All rights reserved.
//

#import "M2HomeViewController.h"
#import "M2SettingsViewController.h"
#import "M2GameCenterManager.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
NSString * const kTableViewidentifierNormalCell = @"TableViewidentifierNormalCell";

@interface M2HomeViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) M2GameCenterManager *gameManager;

@end

@implementation M2HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"主页";
    [self configUI];
}

- (void)configUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [[GSTATE backgroundColor] colorWithAlphaComponent:0.8];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kTableViewidentifierNormalCell];
    
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    }
    return _tableView;
}

#pragma mark -- tableview delegate and datasoure

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewidentifierNormalCell];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    if (indexPath.row == 0) {
        cell.textLabel.text = @"排行榜";
    } else {
        cell.textLabel.text = @"设置";
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self.gameManager showGameCenterWithVC:self];
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        M2SettingsViewController *settingVC = [storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
                UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:settingVC];
        [self presentViewController:navigationVC animated:YES completion:nil];
    }
}

- (M2GameCenterManager *)gameManager {
    if (!_gameManager) {
        _gameManager = [[M2GameCenterManager alloc] init];
    }
    return _gameManager;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
