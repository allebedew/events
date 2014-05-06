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

@end
