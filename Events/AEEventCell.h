//
//  AEEventCell.h
//  Events
//
//  Created by Lebedev Aleksey on 23/3/14.
//  Copyright (c) 2014 Aleksey Lebedev. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const AEEventCellIdentifier;

@class AEEvent;

@interface AEEventCell : UICollectionViewCell

@property (nonatomic, strong) AEEvent *event;

- (void)updateCounterLabels;

@end
