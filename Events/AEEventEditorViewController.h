//
//  AEEventEditorViewController.h
//  Events
//
//  Created by Lebedev Aleksey on 2/4/14.
//  Copyright (c) 2014 Aleksey Lebedev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AEEvent;

@interface AEEventEditorViewController : UITableViewController

- (instancetype)initWithEvent:(AEEvent *)event;
- (instancetype)initWithCreatingNewEvent;

@property (nonatomic, readonly) AEEvent *event;

@end
