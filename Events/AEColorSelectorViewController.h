//
//  AEColorSelectorViewController.h
//  Events
//
//  Created by Lebedev Aleksey on 13/6/14.
//  Copyright (c) 2014 Aleksey Lebedev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AEItemColor;

@interface AEColorSelectorViewController : UITableViewController

@property (nonatomic, strong) AEItemColor *selectedColor;
@property (nonatomic, strong) void (^colorSelectedBlock)(void);

@end
