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
  self.plusView.layer.cornerRadius = 5.0f;

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
