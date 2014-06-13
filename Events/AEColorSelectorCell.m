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

@property (nonatomic, weak) IBOutlet UIView *markView;
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

- (void)prepareMarkView {
  self.gradientLayer = [[CAGradientLayer alloc] init];
  self.gradientLayer.frame = self.markView.bounds;
  [self.markView.layer addSublayer:self.gradientLayer];

  self.markView.layer.cornerRadius = CGRectGetHeight(self.markView.frame) / 2;
  self.markView.layer.borderColor = [UIColor colorWithWhite:0.5f alpha:1.0f].CGColor;
  self.markView.layer.borderWidth = 1.0f;
  self.markView.clipsToBounds = YES;
}

- (void)setColor:(AEItemColor *)color {
  if (_color != color) {
    _color = color;
  }
  [self fillData];
}

- (void)fillData {
  if (self.color) {
    self.gradientLayer.colors = @[(id)[self.color.startColor CGColor],
                                  (id)[self.color.endColor CGColor]];
  } else {
    self.gradientLayer.colors = nil;
  }
  self.colorNameLabel.text = self.color.name;
}

@end
