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

#pragma mark - Realm

+ (NSDictionary *)defaultPropertyValues {
    RLMResults *allObjects = [[self class] allObjects];
    NSInteger nextId = [[allObjects maxOfProperty:[[self class] primaryKey]] integerValue] + 1;
    NSInteger nextOrder = [[allObjects maxOfProperty:@"order"] integerValue] + 1;
    return @{
        @"id": @(nextId),
        @"order": @(nextOrder),
        @"date": [NSDate date],
        @"colorIdentifier": [AEItemColor randomColor].identifier
    };
}

+ (NSString *)primaryKey {
    return @"id";
}

+ (NSArray *)ignoredProperties {
    return @[ @"dateString", @"intervalDateComponents", @"intervalString", @"color" ];
}

+ (NSArray *)requiredProperties {
    return @[ @"title", @"colorIdentifier", @"date" ];
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

  NSUInteger flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |
    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
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
    [stringComponents addObject:[NSString stringWithFormat:@"%ld %@", (long)components.month, unit]];
  }
  if (components.day > 0) {
    NSString *unit = [NSString localizedStringWithFormat:NSLocalizedString(@"%d days", @""), components.day];
    [stringComponents addObject:[NSString stringWithFormat:@"%ld %@", (long)components.day, unit]];
  }
  if (components.hour > 0) {
    NSString *unit = [NSString localizedStringWithFormat:NSLocalizedString(@"%d hours", @""), components.hour];
    [stringComponents addObject:[NSString stringWithFormat:@"%ld %@", (long)components.hour, unit]];
  }
  if (components.minute > 0) {
    NSString *unit = [NSString localizedStringWithFormat:NSLocalizedString(@"%d minutes", @""), components.minute];
    [stringComponents addObject:[NSString stringWithFormat:@"%ld %@", (long)components.minute, unit]];
  }
  if (components.second > 0 || stringComponents.count == 0) {
    NSString *unit = [NSString localizedStringWithFormat:NSLocalizedString(@"%d seconds", @""), components.second];
    [stringComponents addObject:[NSString stringWithFormat:@"%ld %@", (long)components.second, unit]];
  }
  
  if (stringComponents.count > 3) {
    NSString *firstLine = [[stringComponents subarrayWithRange:NSMakeRange(0, 3)] componentsJoinedByString:@", "];
    NSString *secondLine = [[stringComponents subarrayWithRange:NSMakeRange(3, stringComponents.count - 3)] componentsJoinedByString:@", "];
    return [NSString stringWithFormat:@"%@\n%@", firstLine, secondLine];
  } else {
    return [stringComponents componentsJoinedByString:@", "];
  }
}

- (AEItemColor*)color {
  return [AEItemColor colorWithIdentifier:self.colorIdentifier];
}

- (void)setColor:(AEItemColor *)color {
  self.colorIdentifier = color.identifier;
}

@end
