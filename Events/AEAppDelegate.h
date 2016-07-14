//
//  AEAppDelegate.h
//  Events
//
//  Created by Lebedev Aleksey on 23/3/14.
//  Copyright (c) 2014 Aleksey Lebedev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AEAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (AEAppDelegate*)delegate;

- (void)showStatusBarShader:(BOOL)show animated:(BOOL)animated;

@end
