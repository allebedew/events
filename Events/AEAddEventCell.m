//
//  AEAddEventCell.m
//  Events
//
//  Created by Lebedev Aleksey on 31/3/14.
//  Copyright (c) 2014 Aleksey Lebedev. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AEAddEventCell.h"

@interface AEAddEventCell ()

@property (nonatomic, weak) IBOutlet UIView *plusView;

@end

@implementation AEAddEventCell

- (void)awakeFromNib {
  self.backgroundColor = nil;

  self.plusView.layer.cornerRadius = 5.0f;
  self.plusView.layer.shadowColor = [UIColor colorWithWhite:0.0f alpha:1.0f].CGColor;
  self.plusView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
  self.plusView.layer.shadowRadius = 2.0f;
  self.plusView.layer.shadowOpacity = 0.15f;

  [self updateAppearance];
}

- (void)updateAppearance {
  if (self.highlighted || self.selected) {
    self.plusView.backgroundColor = [UIColor colorWithWhite:0.45f alpha:1.0f];
  } else {
    self.plusView.backgroundColor = [UIColor colorWithWhite:0.25f alpha:1.0f];
  }
}

- (void)setSelected:(BOOL)selected {
  [super setSelected:selected];
  [self updateAppearance];
}

- (void)setHighlighted:(BOOL)highlighted {
  [super setHighlighted:highlighted];
  [self updateAppearance];
}

@end
