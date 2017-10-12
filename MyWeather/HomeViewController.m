//
//  HomeViewController.m
//  MMMemorandum
//
//  Created by lijie on 2017/7/17.
//  Copyright © 2017年 lijie. All rights reserved.
//

#import "HomeViewController.h"
//#import "SettingViewController.h"//设置
#import "AddThingsViewController.h"//添加
#import "DetailViewController.h"//详细vc
#import "HomeTableViewCell.h"
#import "HeaderView.h"//显示置顶数据
#import "HomeViewModel.h"
#import "JDWeatherViewModel.h"
#import <CoreLocation/CoreLocation.h>

@interface HomeViewController ()<UITableViewDelegate, UITableViewDataSource, HeaderDelegate, CLLocationManagerDelegate> {
    HeaderView *_headerview;
    HomeViewModel *_viewModel;
    UIVisualEffectView *_eBgView;//毛玻璃view
    BOOL _isChanged;//是否改变
    CGFloat _height;//头视图高度
    JDWeatherViewModel *_weatherViewModel;
}

@property (nonatomic, strong) UIButton *titleTypeBtn;//标题view
@property (nonatomic, strong) NSString *titleStr;//标题
@property (weak, nonatomic) IBOutlet UITableView *memoryTable;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSString *localCity;//定位到的城市

@end

@implementation HomeViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isChanged = NO;
    
    self.titleStr = NSLocalizedString(@"home", nil);
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self initUI];
    
    [self.memoryTable addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isChanged) name:@"dateType" object:nil];
    
    [self startLocation];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self loadWeather];
    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _isChanged = NO;
}

#pragma mark - viewmodel
- (void)initViewModelBinding {
    _viewModel = [[HomeViewModel alloc] init];
    _weatherViewModel = [[JDWeatherViewModel alloc] init];
}

- (void)loadData {
    @weakSelf(self);
    [_viewModel getHomeDataIsChanged:_isChanged success:^(BOOL result) {
        [_headerview setDataWithModel:_viewModel.homeListArr.firstObject];
        if (_viewModel.homeListArr.count <= 0 || _viewModel.homeListArr == nil) {
            [weakSelf setNoDataFooter];
        } else {
            weakSelf.memoryTable.tableFooterView = [UIView new];
        }
        [weakSelf.memoryTable reloadData];
        
    } failure:^(NSString *errorString) {
        NSLog(@"failure");
    }];
}

//
- (void)loadWeather {
    @weakSelf(self);
    [self showWaiting];
    [_weatherViewModel getJDWeatherWithCity:@"上海" success:^(BOOL result) {
        [weakSelf hideWaiting];
        [_headerview getWeatherWithModel:_weatherViewModel.now localCity:self.localCity];
        
    } failure:^(NSError *error) {
        [weakSelf hideWaiting];
        [weakSelf showMassage:error.localizedDescription];
    }];
}

#pragma mark - 事件
- (void)setting {
//    SettingViewController *setVc = [[SettingViewController alloc] init];
//    [self.navigationController pushViewController:setVc animated:YES];
}

- (void)addThings {
    AddThingsViewController *addVc = [[AddThingsViewController alloc] initWithModel:nil];
    [self.navigationController pushViewController:addVc animated:YES];
}

- (void)isChanged {
    _isChanged = YES;
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint point = [change[NSKeyValueChangeNewKey] CGPointValue];
        if (point.y > 181) {
            _eBgView.frame = CGRectMake(0, 64, Screen_Width, Screen_Height-64);
        } else {
            _eBgView.frame = CGRectMake(0, _height+64-point.y, Screen_Width, Screen_Height-(_height+64-point.y));
        }
    }
}

#pragma mark - table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _viewModel.homeListArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeTableViewCell"];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"HomeTableViewCell" owner:nil options:nil].firstObject;
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    HomeModel *model = _viewModel.homeListArr[indexPath.row];
    [cell setDataWithModel:model];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeModel *model = _viewModel.homeListArr[indexPath.row];
    DetailViewController *vc = [[DetailViewController alloc] initWithModel:model];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    ///配置 CATransform3D 动画内容
//    CATransform3D transform; transform.m34 = 1.0/-800;
//    //定义 Cell的初始化状态
//    cell.layer.transform = transform;
//    //定义Cell 最终状态 并且提交动画
//    [UIView beginAnimations:@"transform" context:NULL];
//    [UIView setAnimationDuration:1];
//    cell.layer.transform = CATransform3DIdentity;
//    cell.frame = CGRectMake(0, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
//    [UIView commitAnimations];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1)];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)];
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [cell.layer addAnimation:scaleAnimation forKey:@"transform"];
}

//实现左滑删除方法
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        HomeModel *currentHome = _viewModel.homeListArr[indexPath.row];
        NSMutableArray *newArr = [NSMutableArray arrayWithArray:_viewModel.homeListArr];
        for (HomeModel *home in _viewModel.homeListArr) {
            if ([home.thingId isEqualToString:currentHome.thingId]) {
                [newArr removeObject:home];
            }
        }
        _viewModel.homeListArr = newArr;
        
        //重新保存修改后的数组
        NSString *listFile = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString *listPath = [listFile stringByAppendingPathComponent:@"list.plist"];
        //将修改后的数组重新归档
        [NSKeyedArchiver archiveRootObject:newArr toFile:listPath];
        [_headerview setDataWithModel:_viewModel.homeListArr.firstObject];
        
//        [self.memoryTable reloadData];
        [self loadData];
        
    }
}

//修改删除按钮为中文的删除
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"delete", nil);
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


#pragma mark - UI
- (void)initUI {
    //568
    //667
    //736
    //254*Screen_Height/667
    _height = 181*Screen_Height/667;//避免不同屏幕上直接用254*Screen_Height/667计算出来的差值不等于64,即头视图和模糊视图之间会有空余
//    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, _height)];
    header.backgroundColor = [UIColor clearColor];
    self.memoryTable.tableHeaderView = header;
    self.memoryTable.tableFooterView = [UIView new];
    self.memoryTable.separatorColor = [UIColor grayColor];
    [self setNavbar];
    
    _eBgView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    _eBgView.frame = CGRectMake(0, _height+64, Screen_Width, Screen_Height-_height-64);
    _eBgView.alpha = 0.8;
    [self.view addSubview:_eBgView];
    [self.view insertSubview:_eBgView belowSubview:self.memoryTable];
}

- (void)setNavbar {
    UIButton *meBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    meBtn.frame = CGRectMake(0, 0, 23, 22);
    [meBtn setImage:[UIImage imageNamed:@"me"] forState:UIControlStateNormal];
    [meBtn addTarget:self action:@selector(setting) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(0, 0, 22, 22);
    [addBtn setImage:[UIImage imageNamed:@"addgray"] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addThings) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleTypeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.titleTypeBtn.frame = CGRectMake(0, 0, 200, 40);
    [self.titleTypeBtn setTitle:self.titleStr forState:UIControlStateNormal];
    [self.titleTypeBtn setTitleColor:FontColor forState:UIControlStateNormal];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:meBtn];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:addBtn];
    
    [self addNavigationWithTitle:nil leftItem:leftItem rightItem:rightItem titleView:self.titleTypeBtn];
    
    [self setHeader];
}

- (void)setHeader {
    if (_headerview == nil) {
        _headerview = [[NSBundle mainBundle] loadNibNamed:@"HeaderView" owner:nil options:nil].firstObject;
        _headerview.frame = CGRectMake(0, 64, Screen_Width, _height);
    }
    _headerview.delegate = self;
    
    
    [self.view addSubview:_headerview];
    [self.view sendSubviewToBack:_headerview];
}

- (void)setNoDataFooter {
    UIView *footview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, 200*Heigt_Scale)];
    UILabel *hintLab = [[UILabel alloc] initWithFrame:CGRectMake(0, (200-50)*Heigt_Scale, Screen_Width, 40*Heigt_Scale)];
//    hintLab.center = footview.center;
    hintLab.textAlignment = NSTextAlignmentCenter;
    hintLab.text = NSLocalizedString(@"adddata", nil);
    hintLab.textColor = [UIColor whiteColor];
    hintLab.font = [UIFont systemFontOfSize:20];
    [footview addSubview:hintLab];
    
    UIImageView *imgview = [[UIImageView alloc] initWithFrame:CGRectMake((Screen_Width-120*Width_Scale)/2, 20, 120*Width_Scale, 120*Width_Scale)];
    imgview.image = [UIImage imageNamed:@"haha"];
    [footview addSubview:imgview];
    self.memoryTable.tableFooterView = footview;
}

#pragma mark - 定位
//开始定位
- (void)startLocation {
    if ([CLLocationManager locationServicesEnabled]){
        //        CLog(@"--------开始定位");
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self; //控制定位精度,越高耗电量越
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer; // 总是授权
        [self.locationManager requestAlwaysAuthorization];
        self.locationManager.distanceFilter = 10.0f;
        [self.locationManager requestAlwaysAuthorization];
        [self.locationManager startUpdatingLocation];
    }
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error code] == kCLErrorDenied) {
        NSLog(@"访问被拒绝");
    }
    if ([error code] == kCLErrorLocationUnknown) {
        NSLog(@"无法获取位置信息");
    }
}
//定位代理经纬度回调
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation *newLocation = locations[0];
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *array, NSError *error){
        if (array.count > 0) {
            CLPlacemark *placemark = [array objectAtIndex:0];
            //获取城市
            self.localCity = placemark.locality;
            self.localCity = [self.localCity stringByReplacingOccurrencesOfString:@"市" withString:@""];
            
            if (!self.localCity) {
                //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                self.localCity = placemark.administrativeArea;
            }
            
            [self loadWeather];
            NSLog(@"city定位城市 %@", self.localCity);
            
        } else if (error == nil && [array count] == 0) {
            NSLog(@"No results were returned.");
            [self showMassage:@"No results were returned."];
        } else if (error != nil) {
            NSLog(@"An error occurred = %@", error);
//            [self showMassage:error.localizedDescription];
        }
    }];
    
    //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
    [manager stopUpdatingLocation];
}

#pragma mark - dealloc
- (void)dealloc {
    [self.memoryTable removeObserver:self forKeyPath:@"distance"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _isChanged = NO;
}

@end
