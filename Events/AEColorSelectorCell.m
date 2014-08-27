//
//  AEColorSelectorCell.m
//  Events
//
//  Created by Lebedev Aleksey on 13/6/14.
//  Copyright (c) 2014 Aleksey Lebedev. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AEColorSelectorCell.h"

#import "AEItemColor.h"

@interface AEColorSelectorCell ()

@property (nonatomic, weak) IBOutlet UIView *colorView;
@property (nonatomic, weak) IBOutlet UILabel *colorNameLabel;

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation AEColorSelectorCell

- (void)awakeFromNib {
  [self fillData];
  [self prepareMarkView];
}

- (void)prepareForReuse {
  self.color = nil;
}

- (void)setColor:(AEItemColor *)color {
  if (_color != color) {
    _color = color;
  }
  [self fillData];
}

#pragma mark - Private

- (void)prepareMarkView {
  self.gradientLayer = [[CAGradientLayer alloc] init];
  self.gradientLayer.frame = self.colorView.bounds;
  [self.colorView.layer addSublayer:self.gradientLayer];

  self.colorView.layer.cornerRadius = CGRectGetHeight(self.colorView.frame) / 2;
  self.colorView.clipsToBounds = YES;
}


- (void)fillData {
  self.colorNameLabel.text = self.color.name;

  if (self.color) {
    self.gradientLayer.colors = @[(id)[self.color.startColor CGColor],
                                  (id)[self.color.startColor CGColor]];
  } else {
    self.gradientLayer.colors = nil;
  }
}

@end
