//
//  AEEventEditorViewController.h
//  Events
//
//  Created by Lebedev Aleksey on 2/4/14.
//  Copyright (c) 2014 Aleksey Lebedev. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AEEventEditorViewControllerCompletion)(BOOL cancelled);

@class AEEvent;

@interface AEEventEditorViewController : UITableViewController

@property (nonatomic, strong) AEEvent *event;
@property (nonatomic, copy) AEEventEditorViewControllerCompletion completion;

@end
