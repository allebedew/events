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

+ (AEEvent*)eventWithTitle:(NSString*)title date:(NSDate*)date color:(AEItemColor*)color
                   context:(NSManagedObjectContext*)context insert:(BOOL)insert {
  if (!context) {
    context = [AEAppDelegate delegate].managedObjectContext;
  }
  NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event"
                                            inManagedObjectContext:context];
  AEEvent *event = [[AEEvent alloc] initWithEntity:entity
                    insertIntoManagedObjectContext:insert ? context : nil];
  event.title = title;
  event.date = date ? date : [NSDate date];
  event.color = color ? color : [AEItemColor randomColor];
  event.order = @([[[AEAppDelegate delegate] fetchLastOrderValue] integerValue] + 1);
  return event;
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
  if (components.second > 0) {
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
