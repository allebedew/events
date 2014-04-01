//
//  Entity.m
//  Events
//
//  Created by Lebedev Aleksey on 30/3/14.
//  Copyright (c) 2014 Aleksey Lebedev. All rights reserved.
//

#import "AEEvent.h"

@implementation AEEvent

@dynamic date, title, order;

- (NSNumber*)fetchNextOrderValue {
  NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
  req.sortDescriptors = @[ [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:NO] ];
  req.fetchLimit = 1;
  req.resultType = NSDictionaryResultType;
  req.propertiesToFetch = @[ self.entity.propertiesByName[@"order"] ];
  NSError *error = nil;
  NSArray *result = [self.managedObjectContext executeFetchRequest:req error:&error];
  NSNumber *maxOrder = result.firstObject[@"order"];
  if (error) {
    NSLog(@"max order fetch error: %@", error);
    return nil;
  }
  return @(maxOrder.integerValue + 1);
}

- (void)awakeFromInsert {
  [self setPrimitiveValue:[self fetchNextOrderValue] forKey:@"order"];
  [self setPrimitiveValue:@"New Event" forKey:@"title"];
  [self setPrimitiveValue:[NSDate date] forKey:@"date"];
}

#pragma mark - Custom Properties

- (NSString*)timeIntervalString {
  if (!self.date) {
    return nil;
  }

  NSUInteger flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit
    | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
  NSDate *now = [NSDate date];
  NSDateComponents *components = [[NSCalendar currentCalendar] components:flags
                                                                 fromDate:[self.date earlierDate:now]
                                                                   toDate:[self.date laterDate:now]
                                                                  options:0];

  NSMutableArray *dateStrings = [NSMutableArray arrayWithCapacity:6];
  if ((components.year > 0) && (flags & NSYearCalendarUnit)) {
    NSString *string = [NSString stringWithFormat:NSLocalizedString(@"%d year", @""), components.year];
    [dateStrings addObject:string];
  }
  if ((components.month > 0) && (flags & NSMonthCalendarUnit)) {
    NSString *string = [NSString stringWithFormat:NSLocalizedString(@"%d month", @""), components.month];
    [dateStrings addObject:string];
  }
  if (((components.day > 0) && (flags & NSDayCalendarUnit)) || !(flags & NSHourCalendarUnit)) {
    NSString *string = [NSString stringWithFormat:NSLocalizedString(@"%d day", @""), components.day];
    [dateStrings addObject:string];
  }
  NSString *string = [dateStrings componentsJoinedByString:@" "];

  if (flags & NSHourCalendarUnit) {
    NSString *timeString = [NSString stringWithFormat:@"\n%d:%.2d:%.2d", components.hour, components.minute, components.second];
    return [NSString stringWithFormat:@"%@\n%@", string, timeString];
  }

  return string;
}

@end
