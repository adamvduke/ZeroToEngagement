//
//  ZEAppDelegate.m
//  ZeroToEngagementiOS
//
//  Created by Adam Duke on 7/11/13.
//  Copyright (c) 2013 ZeroPush. All rights reserved.
//

#import "ZEAppDelegate.h"

#import "ZEViewController.h"

@implementation ZEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[ZEViewController alloc] initWithNibName:@"ZEViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /* Every time the app becomes active,
     attempt to register */
    [application registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge |
      UIRemoteNotificationTypeSound |
      UIRemoteNotificationTypeAlert)];
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    /* Turn the data into a string.
     Someone will tell me I can do this with a regex */
    NSString *token = [deviceToken description];
    token = [token stringByReplacingOccurrencesOfString:@"<"
                                             withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">"
                                             withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@" "
                                             withString:@""];
    
    NSLog(@"%@", token);
    /* TODO: Save the string along with a
     user id to the server so we can
     know which devices belong to whom. */
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"%@", [userInfo description]);
}

@end
