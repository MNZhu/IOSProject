//
//  SUPAppDelegate.m
//  SuperProject
//
//  Created by NShunJian on 2018/1/20.
//  Copyright © 2018年 superMan. All rights reserved.
//

#import "SUPAppDelegate.h"
#import "SUPTabBarController.h"
#import "SUPIntroductoryPagesHelper.h"
#import "AdvertiseHelper.h"
#import "YYFPSLabel.h"
#import "SUPGuidePushView.h"
#import "SUPLoginViewController.h"
#import "WJYAlertView.h"
#import "SUPUMengHelper.h"
#import "SUPUMeng.h"
#import <UserNotificationsUI/UserNotificationsUI.h>
#import <SMS_SDK/SMSSDK+ContactFriends.h>
#import "SYSafeCategory.h"
#import "CYLPlusButtonSubclass.h"
@interface SUPAppDelegate ()
@property(nonatomic, strong)BMKMapManager* mapManager;;
@end

@implementation SUPAppDelegate
- (UIWindow *)window
{
    if(!_window)
    {
        _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_window makeKeyAndVisible];
    }
    return _window;
}
- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        NSLog(@"联网成功");
    }
    else{
        NSLog(@"onGetNetworkState %d",iError);
    }
    
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        NSLog(@"授权成功");
    }
    else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}

- (void)onCheckPermissionState:(BMKLocationAuthErrorCode)iError
{
    NSLog(@"location auth onGetPermissionState %ld",(long)iError);
    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   //  这个百度地图对应 SUPBaiduMapViewController.h  这个类/////////////////////////
    
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    if ([BMKMapManager setCoordinateTypeUsedInBaiduMapSDK:BMK_COORDTYPE_BD09LL]) {
        NSLog(@"经纬度类型设置成功");
    } else {
        NSLog(@"经纬度类型设置失败");
    }
    [[BMKLocationAuth sharedInstance] checkPermisionWithKey:@"xYCkm8cw58M4ynpYB24xlT2LcVMdeBHD" authDelegate:self];
    BOOL ret = [_mapManager start:@"xYCkm8cw58M4ynpYB24xlT2LcVMdeBHD" generalDelegate:self];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
//////////////////////////////////////////////////////////////////////////////////
    
 /*  这个只是在启动时定位 与上面的是同样的只是写法不一样 */
    //地图定位初始化
    [MPLocationManager installMapSDK];
    //百度地图定位
    [[MPLocationManager shareInstance] startBMKLocationWithReg:^(BMKUserLocation *loction, NSError *error) {
        if (error) {
            SUPLog(@"定位失败,失败原因：%@",error);
        }
        else
        {
            SUPLog(@"定位信息：%f,%f",loction.location.coordinate.latitude,loction.location.coordinate.longitude);
            
            CLGeocoder *geocoder=[[CLGeocoder alloc]init];
            [geocoder reverseGeocodeLocation:loction.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                
                //处理手机语言 获得城市的名称（中文）
                NSMutableArray *userDefaultLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
                NSString *currentLanguage = [userDefaultLanguages objectAtIndex:0];
                //如果不是中文 则强制先转成中文 获得后再转成默认语言
                if (![currentLanguage isEqualToString:@"zh-Hans"]&&![currentLanguage isEqualToString:@"zh-Hans-CN"]) {
                    //IOS9前后区分
                    if (isIOS9) {
                        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"zh-Hans-CN", nil] forKey:@"AppleLanguages"];
                    }
                    else
                    {
                        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"zh-Hans", nil] forKey:@"AppleLanguages"];
                    }
                }
                
                //转换地理信息
                if (placemarks.count>0) {
                    CLPlacemark *placemark=[placemarks objectAtIndex:0];
                    //获取城市
                    NSString *city = placemark.locality;
                    if (!city) {
                        //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                        city = placemark.administrativeArea;
                    }
                    
                    NSLog(@"百度当前城市：[%@]",city);
                    
                    // 城市名传出去后,立即 Device 语言 还原为默认的语言
                    [[NSUserDefaults standardUserDefaults] setObject:userDefaultLanguages forKey:@"AppleLanguages"];
                }
            }];
        }
    }];
    
    //系统自带定位
    //    [[MPLocationManager shareInstance]  startSystemLocationWithRes:^(CLLocation *loction, NSError *error) {
    //        DDLogError(@"系统自带定位信息：%f,%f",loction.coordinate.latitude,loction.coordinate.longitude);
    //    }];
    
    
  /*   //////////////////////////////////////                 */
    
   
    //短信验证
    [SMSSDK enableAppContactFriends:YES];
    
    //publicButton
    [CYLPlusButtonSubclass registerPlusButton];
    
    [self setupLoginViewController];
    
    if (![GVUserDefaults standardUserDefaults].isLanuchedApp) {
        // 欢迎视图
        [SUPIntroductoryPagesHelper showIntroductoryPageView:@[@"intro_0.jpg", @"intro_1.jpg", @"intro_2.jpg", @"intro_3.jpg"]];
    }
    
    NSArray <NSString *> *imagesURLS = @[@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1495189872684&di=03f9df0b71bb536223236235515cf227&imgtype=0&src=http%3A%2F%2Fatt1.dzwww.com%2Fforum%2F201405%2F29%2F1033545qqmieznviecgdmm.gif", @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1495189851096&di=224fad7f17468c2cc080221dd78a4abf&imgtype=0&src=http%3A%2F%2Fimg3.duitang.com%2Fuploads%2Fitem%2F201505%2F12%2F20150512124019_GPjEJ.gif"];
    // 启动广告
    [AdvertiseHelper showAdvertiserView:imagesURLS];
    
    //iOS查看屏幕帧数工具   刷新率
     [self.window addSubview:[[YYFPSLabel alloc] initWithFrame:CGRectMake(20, 70, 0, 0)]];
    
    //导向页
     [SUPGuidePushView showGuideView];
    
    // 友盟统计
    [SUPUMengHelper UMAnalyticStart];
    [SUPUMeng UMSocialShare];//要放在地下调用, 不然setPreDefinePlatforms这个方法会崩
    
    // 友盟社交化
     [SUPUMengHelper UMSocialStart];
    
    // 友盟推送
    [SUPUMengHelper UMPushStart:launchOptions];
    
    //键盘统一收回处理
    [self configureBoardManager];
    
    //统一处理一些为数组、集合等对nil插入会引起闪退
    [SYSafeCategory callSafeCategory];
    
    //清空未读标识
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    if (launchOptions) {
        
        [WJYAlertView showOneButtonWithTitle:@"有launchOptions!!" Message:launchOptions.description ButtonType:WJYAlertViewButtonTypeCancel ButtonTitle:@"知道了" Click:^{
            NSLog(@"是的有  launchOptions");
        }];
        
        
    }
    
    
    return YES;
}

//登录页面
-(void)setupLoginViewController{
    
    SUPLoginViewController *login = [[SUPLoginViewController alloc]init];
    self.window.rootViewController = login;
    [self.window makeKeyAndVisible];
    
}
//进入主页
-(void)setUpHomeViewController{
    // 设置主窗口,并设置根控制器
    [CYLPlusButtonSubclass registerPlusButton];
    SUPTabBarController *tabBarControllerConfig = [[SUPTabBarController alloc] init];
    CYLTabBarController *tabBarController = tabBarControllerConfig.tabBarController;
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    [self.window addSubview:[[YYFPSLabel alloc] initWithFrame:CGRectMake(20, 70, 0, 0)]];
    
    
    
//    SUPTabBarController *main = [[SUPTabBarController alloc] init];
//    self.window.rootViewController = main;
//    self.window.backgroundColor = [UIColor whiteColor];
//    [self.window makeKeyAndVisible];
//    [self.window addSubview:[[YYFPSLabel alloc] initWithFrame:CGRectMake(20, 70, 0, 0)]];

}
#pragma mark -应用跳转
//Universal link
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler
{
    if (userActivity.webpageURL) {
        
        NSLog(@"%@", userActivity.webpageURL);
        
        [UIAlertController mj_showAlertWithTitle:@"web跳转应用" message:userActivity.webpageURL.description appearanceProcess:^(JXTAlertController * _Nonnull alertMaker) {
            
            alertMaker.addActionDefaultTitle(@"确认");
        } actionsBlock:^(NSInteger buttonIndex, UIAlertAction * _Nonnull action, JXTAlertController * _Nonnull alertSelf) {
            
        }];
    }
    
    return YES;
    
    //如果使用了Universal link ，此方法必写
    //    return [MWApi continueUserActivity:userActivity];
    
}

//iOS9+scheme跳转
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(nonnull NSDictionary *)options
{
    //必写
    //        [MWApi routeMLink:url];
    
    //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url options:options];
    
    if (!result) {
        // 其他如支付等SDK的回调
        
    }
    
    if (url) {
        NSLog(@"%@", url);
        [UIAlertController mj_showAlertWithTitle:@"iOS9+scheme跳转应用" message:url.description appearanceProcess:^(JXTAlertController * _Nonnull alertMaker) {
            
            alertMaker.addActionDefaultTitle(@"确认");
        } actionsBlock:^(NSInteger buttonIndex, UIAlertAction * _Nonnull action, JXTAlertController * _Nonnull alertSelf) {
            
        }];
        
    }
    
    
    return result;
}

// 支持所有iOS9以下系统,scheme 跳转
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //必写
    //    [MWApi routeMLink:url];
    
    //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    
    if (!result) {
        // 其他如支付等SDK的回调
    }
    if (url) {
        
        NSLog(@"%@", url);
        
        NSLog(@"%@", url);
        [UIAlertController mj_showAlertWithTitle:@"iOS9以下系统scheme跳转应用" message:url.description appearanceProcess:^(JXTAlertController * _Nonnull alertMaker) {
            
            alertMaker.addActionDefaultTitle(@"确认");
        } actionsBlock:nil];
        
    }
    
    return result;
}


#pragma mark - deviceToken
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString * string =[[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]
                         stringByReplacingOccurrencesOfString: @">" withString: @""]
                        stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSLog(@"%@", string);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //        [[EMClient sharedClient] bindDeviceToken:deviceToken];
    });
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    
    NSLog(@"注册远程通知失败: %@", error);
    // 将下面C函数的函数地址当做参数
    //    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
}



#pragma mark - 通知
//iOS10新增：处理前台收到通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{

    NSDictionary * userInfo = notification.request.content.userInfo;

    if (@available(iOS 10.0, *)) {
        if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
            //应用处于前台时的远程推送接受
            //关闭U-Push自带的弹出框
            [UMessage setAutoAlert:NO];
            //必须加这句代码
            [UMessage didReceiveRemoteNotification:userInfo];

            [UIAlertController mj_showAlertWithTitle:@"2_iOS10新增：处理前台收到通知的代理方法" message:userInfo.description appearanceProcess:^(JXTAlertController * _Nonnull alertMaker) {

                alertMaker.addActionDefaultTitle(@"确认");
            } actionsBlock:nil];

        }else{
            //应用处于前台时的本地推送接受
        }
    } else {
        // Fallback on earlier versions
    }
    //当应用处于前台时提示设置，需要哪个可以设置哪一个
    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
}

//iOS10新增：处理后台点击通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler{

    NSDictionary * userInfo = response.notification.request.content.userInfo;
    NSLog(@"%@",userInfo);
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {

        //应用处于后台时的远程推送接受
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        [UIAlertController mj_showAlertWithTitle:@"3_iOS10新增：处理后台点击通知的代理方法" message:userInfo.description appearanceProcess:^(JXTAlertController * _Nonnull alertMaker) {
            alertMaker.addActionDefaultTitle(@"确认");
        } actionsBlock:nil];
    }else{
        //应用处于后台时的本地推送接受
    }
}


//iOS10以下使用这两个方法接收通知，
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [UMessage setAutoAlert:NO];
    if([[[UIDevice currentDevice] systemVersion]intValue] < 10){
        [UMessage didReceiveRemoteNotification:userInfo];
        
//            self.userInfo = userInfo;
            //定制自定的的弹出框
            if([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"标题"
                                                                    message:@"Test On ApplicationStateActive"
                                                                   delegate:self
                                                          cancelButtonTitle:@"确定"
                                                          otherButtonTitles:nil];
        
                [alertView show];
        
            }
        completionHandler(UIBackgroundFetchResultNewData);
    }
}


//iOS10以下使用这个方法接收通知
//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
//{
//    //关闭U-Push自带的弹出框
//    [UMessage setAutoAlert:NO];
//    [UMessage didReceiveRemoteNotification:userInfo];
//
//    //    self.userInfo = userInfo;
//    //    //定制自定的的弹出框
//    //    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
//    //    {
//    //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"标题"
//    //                                                            message:@"Test On ApplicationStateActive"
//    //                                                           delegate:self
//    //                                                  cancelButtonTitle:@"确定"
//    //                                                  otherButtonTitles:nil];
//    //
//    //        [alertView show];
//    //
//    //    }
//}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}




#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"MqttText"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}


#pragma mark 键盘收回管理
-(void)configureBoardManager
{
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
    manager.shouldResignOnTouchOutside = YES;
    manager.shouldToolbarUsesTextFieldTintColor = YES;
    manager.keyboardDistanceFromTextField=60;
    manager.enableAutoToolbar = NO;
}
@end
