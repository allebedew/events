//
//  Entity.m
//  Events
//
//  Created by Lebedev Aleksey on 30/3/14.
//  Copyright (c) 2014 Aleksey Lebedev. All rights reserved.
//

#import "AEEvent.h"

#import "AEAppDelegate.h"
#import "AEItemColor.h"

@implementation AEEvent

@dynamic date, title, order, colorIdentifier;

#pragma mark - Public

- (void)setInitialValues {
  self.order = @([[[AEAppDelegate delegate] fetchLastOrderValue] integerValue] + 1);
  self.color = [AEItemColor randomColor];
  self.date = [NSDate date];
}

#pragma mark - Custom Properties

- (NSString*)dateString {
  static NSDateFormatter *dateFormatter = nil;
  if (!dateFormatter) {
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
  }
  return [dateFormatter stringFromDate:self.date];
}

- (NSDateComponents*)intervalDateComponents {
  if (!self.date) {
    return nil;
  }

  NSUInteger flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
  NSDate *now = [NSDate date];
  return [[NSCalendar currentCalendar] components:flags
                                         fromDate:[self.date earlierDate:now]
                                           toDate:[self.date laterDate:now]
                                          options:0];
}

- (NSString*)intervalString {
  NSDateComponents *components = self.intervalDateComponents;
  NSMutableArray *stringComponents = [NSMutableArray array];
  if (components.year > 0) {
    NSString *unit = [NSString localizedStringWithFormat:NSLocalizedString(@"%d years", @""), components.year];
    [stringComponents addObject:[NSString stringWithFormat:@"%ld %@", (long)components.year, unit]];
  }
  if (components.month > 0) {
    NSString *unit = [NSString localizedStringWithFormat:NSLocalizedString(@"%d months", @""), components.month];
    [stringComponents addObject:[NSString stringWithFormat:@"%ld %@", components.month, unit]];
  }
  if (components.day > 0) {
    NSString *unit = [NSString localizedStringWithFormat:NSLocalizedString(@"%d days", @""), components.day];
    [stringComponents addObject:[NSString stringWithFormat:@"%ld %@", components.day, unit]];
  }
  if (components.hour > 0) {
    NSString *unit = [NSString localizedStringWithFormat:NSLocalizedString(@"%d hours", @""), components.hour];
    [stringComponents addObject:[NSString stringWithFormat:@"%ld %@", components.hour, unit]];
  }
  if (components.minute > 0) {
    NSString *unit = [NSString localizedStringWithFormat:NSLocalizedString(@"%d minutes", @""), components.minute];
    [stringComponents addObject:[NSString stringWithFormat:@"%ld %@", components.minute, unit]];
  }
  if (components.second > 0) {
    NSString *unit = [NSString localizedStringWithFormat:NSLocalizedString(@"%d seconds", @""), components.second];
    [stringComponents addObject:[NSString stringWithFormat:@"%ld %@", components.second, unit]];
  }
  return [stringComponents componentsJoinedByString:@", "];
}

- (AEItemColor*)color {
  return [AEItemColor colorWithIdentifier:self.colorIdentifier];
}

- (void)setColor:(AEItemColor *)color {
  self.colorIdentifier = color.identifier;
}

@end
