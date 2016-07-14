//
//  AEAppDelegate.h
//  Events
//
//  Created by Lebedev Aleksey on 23/3/14.
//  Copyright (c) 2014 Aleksey Lebedev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AEAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, readonly) BOOL isFirstLaunch;

+ (AEAppDelegate*)delegate;

- (void)showStatusBarShader:(BOOL)show animated:(BOOL)animated;

@end
