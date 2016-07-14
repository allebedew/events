
//  AEAppDelegate.m
//  Events
//
//  Created by Lebedev Aleksey on 23/3/14.
//  Copyright (c) 2014 Aleksey Lebedev. All rights reserved.
//

#import "AEAppDelegate.h"

#import "AEEvent.h"
#import "AEItemColor.h"
#import "AEDataStore.h"

@interface AEAppDelegate ()

@property (nonatomic, strong) UIView *statusBarShader;
@property (nonatomic, assign) BOOL isFirstLaunch;

@end

@implementation AEAppDelegate

+ (AEAppDelegate*)delegate {
    return [UIApplication sharedApplication].delegate;
}

#pragma mark - App Delegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self checkFirstLaunch];
    [AEDataStore doStartupActions];
    [self performSelector:@selector(updateStatusBarShaderFrame) withObject:nil afterDelay:0.0f];
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)application:(UIApplication *)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation {
    [self performSelector:@selector(updateStatusBarShaderFrame) withObject:nil afterDelay:0.0f];
}

#pragma mark - Private

- (void)checkFirstLaunch {
    static NSString *AEFirstLaunchDefaultsKey = @"AEFirstLaunch";
    if ([[NSUserDefaults standardUserDefaults] doubleForKey:AEFirstLaunchDefaultsKey] == 0.0) {
        self.isFirstLaunch = YES;
        [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970] forKey:AEFirstLaunchDefaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Public

- (UIView*)statusBarShader {
    if (!_statusBarShader) {
        _statusBarShader = [[UIView alloc] init];
        _statusBarShader.backgroundColor = [UIColor colorWithWhite:0.205f alpha:0.75f];
    }
    return _statusBarShader;
}

- (void)updateStatusBarShaderFrame {
    self.statusBarShader.frame = [UIApplication sharedApplication].statusBarFrame;
}

- (void)showStatusBarShader:(BOOL)show animated:(BOOL)animated {
    if (show && !self.statusBarShader.superview) {
        [self.window addSubview:self.statusBarShader];
        [self.window performSelector:@selector(bringSubviewToFront:)
                          withObject:self.statusBarShader
                          afterDelay:0.0f]; // dirty
    }
    dispatch_block_t animations = ^{
        self.statusBarShader.alpha = show ? 1.0f : 0.0f;
    };
    if (animated) {
        [UIView animateWithDuration:0.3f animations:animations];
    } else {
        animations();
    }
}

@end

@implementation UINavigationController (Rotation)

- (NSUInteger)supportedInterfaceOrientations {
    if (self.topViewController.presentedViewController) {
        return self.topViewController.presentedViewController.supportedInterfaceOrientations;
    }
    return self.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}

@end
