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
#import "AEItemColor.h"

NSString * const AEEventCellIdentifier = @"AEEventCellIdentifier";

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
  self.backgroundView.backgroundColor = [[[AEItemColor availableColors] firstObject] startColor];

  self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
  self.selectedBackgroundView.layer.cornerRadius = 5.0f;
  self.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.35f];
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
  _event = event;

  [self updateEventData];
  [self updateCounterLabels];
  [self setNeedsLayout];
}

- (void)updateEventData {
  self.titleLabel.text = self.event.title;
  self.dateLabel.text = self.event.dateString;

  self.backgroundView.backgroundColor = self.event.color.startColor;
}

- (void)updateCounterLabels {
  NSDateComponents *components = self.event.intervalDateComponents;
  self.yearLabel.text = [NSString stringWithFormat:@"%.1ld", (long)components.year];
  self.yearUnitLabel.text =
    [[NSString localizedStringWithFormat:
      NSLocalizedString(@"%d years", @""), components.year] uppercaseString];


  self.monthLabel.text = [NSString stringWithFormat:@"%.1ld", (long)components.month];
  self.monthUnitLabel.text =
    [[NSString localizedStringWithFormat:
      NSLocalizedString(@"%d months", @""), components.month] uppercaseString];

  self.dayLabel.text = [NSString stringWithFormat:@"%.1ld", (long)components.day];
  self.dayUnitLabel.text =
    [[NSString localizedStringWithFormat:
      NSLocalizedString(@"%d days", @""), components.day] uppercaseString];

  self.hourLabel.text = [NSString stringWithFormat:@"%.1ld", (long)components.hour];
  self.hourUnitLabel.text =
    [[NSString localizedStringWithFormat:
      NSLocalizedString(@"%d hours", @""), components.hour] uppercaseString];

  self.minuteLabel.text = [NSString stringWithFormat:@"%.2ld", (long)components.minute];
  self.minuteUnitLabel.text =
    [[NSString localizedStringWithFormat:
      NSLocalizedString(@"%d minutes", @""), components.minute] uppercaseString];

  self.secondLabel.text = [NSString stringWithFormat:@"%.2ld", (long)components.second];
  self.secondUnitLabel.text =
    [[NSString localizedStringWithFormat:
      NSLocalizedString(@"%d seconds", @""), components.second] uppercaseString];
}

@end
