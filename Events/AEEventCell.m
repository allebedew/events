//
//  AEEventCell.m
//  Events
//
//  Created by Lebedev Aleksey on 23/3/14.
//  Copyright (c) 2014 Aleksey Lebedev. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AEEventCell.h"
#import "AEEvent.h"

@interface AEEventCell ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;

@end

@implementation AEEventCell

- (void)awakeFromNib {
  self.layer.cornerRadius = 5.0f;
}

- (void)prepareForReuse {
  self.event = nil;
}

- (void)setEvent:(AEEvent *)event {
  if (_event != event) {
    _event = event;
    [self updateContent];
  }
}

- (void)updateContent {
  self.titleLabel.text = self.event.title;
  self.dateLabel.text = self.event.timeIntervalString;
}

@end
