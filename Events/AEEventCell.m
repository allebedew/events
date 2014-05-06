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
@property (nonatomic, weak) IBOutlet UILabel *yearLabel;
@property (nonatomic, weak) IBOutlet UILabel *yearUnitLabel;
@property (nonatomic, weak) IBOutlet UILabel *monthLabel;
@property (nonatomic, weak) IBOutlet UILabel *monthUnitLabel;
@property (nonatomic, weak) IBOutlet UILabel *dayLabel;
@property (nonatomic, weak) IBOutlet UILabel *dayUnitLabel;
@property (nonatomic, weak) IBOutlet UILabel *hourLabel;
@property (nonatomic, weak) IBOutlet UILabel *hourUnitLabel;
@property (nonatomic, weak) IBOutlet UILabel *minuteLabel;
@property (nonatomic, weak) IBOutlet UILabel *minuteUnitLabel;
@property (nonatomic, weak) IBOutlet UILabel *secondLabel;
@property (nonatomic, weak) IBOutlet UILabel *secondUnitLabel;

@end

@implementation AEEventCell

- (void)awakeFromNib {
  self.backgroundColor = nil;

  self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
  self.backgroundView.layer.cornerRadius = 5.0f;
  self.backgroundView.layer.shadowColor = [UIColor colorWithWhite:0.0f alpha:1.0f].CGColor;
  self.backgroundView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
  self.backgroundView.layer.shadowRadius = 3.0f;
  self.backgroundView.layer.shadowOpacity = 0.25f;
  self.backgroundView.backgroundColor = [UIColor colorWithHue:0.6f saturation:0.81f
                                                   brightness:0.93f alpha:1.0f];

  self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
  self.selectedBackgroundView.layer.cornerRadius = 5.0f;
  self.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
}

- (void)prepareForReuse {
  self.event = nil;
}

- (void)layoutSubviews {
  CGRect titleRect = [self.titleLabel textRectForBounds:self.titleLabel.superview.bounds
                                 limitedToNumberOfLines:self.titleLabel.numberOfLines];
  CGRect dateRect = [self.dateLabel textRectForBounds:self.dateLabel.superview.bounds
                               limitedToNumberOfLines:self.dateLabel.numberOfLines];

  CGFloat totalHeight = titleRect.size.height + 3.0f + dateRect.size.height;
  titleRect.origin.y = floorf((self.titleLabel.superview.bounds.size.height - totalHeight) / 2.0f);
  dateRect.origin.y = titleRect.origin.y + titleRect.size.height + 3.0f;

  self.titleLabel.frame = titleRect;
  self.dateLabel.frame = dateRect;
}

#pragma mark - Public

- (void)setEvent:(AEEvent *)event {
  if (_event != event) {
    _event = event;
    [self updateContent];
  }
}

- (void)updateContent {
  self.titleLabel.text = self.event.title;
  self.dateLabel.text = self.event.dateString;
  [self updateCounterLabels];
  [self setNeedsLayout];
}

- (void)updateCounterLabels {
  NSDateComponents *components = self.event.intervalDateComponents;
  self.yearLabel.text = [NSString stringWithFormat:@"%.1d", components.year];
  self.yearUnitLabel.text = NSLocalizedString(@"YEARS", @"");
  self.monthLabel.text = [NSString stringWithFormat:@"%.1d", components.month];
  self.monthUnitLabel.text = NSLocalizedString(@"MONTH", @"");
  self.dayLabel.text = [NSString stringWithFormat:@"%.1d", components.day];
  self.dayUnitLabel.text = NSLocalizedString(@"DAYS", @"L");
  self.hourLabel.text = [NSString stringWithFormat:@"%.1d", components.hour];
  self.hourUnitLabel.text = NSLocalizedString(@"HOURS", @"");
  self.minuteLabel.text = [NSString stringWithFormat:@"%.2d", components.minute];
  self.minuteUnitLabel.text = NSLocalizedString(@"MINUTE", @"");
  self.secondLabel.text = [NSString stringWithFormat:@"%.2d", components.second];
  self.secondUnitLabel.text = NSLocalizedString(@"SECONDS", @"");
}

@end
