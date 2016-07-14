//
//  AEDataStore.m
//  Events
//
//  Created by AL on 14/7/16.
//  Copyright © 2016 Aleksey Lebedev. All rights reserved.
//

#import "AEDataStore.h"
#import "AEAppDelegate.h"
#import "AEEvent.h"
#import "AEItemColor.h"
#import "RLMObject+AEExtentions.h"

@implementation AEDataStore

+ (void)doStartupActions {
    if ([AEAppDelegate delegate].isFirstLaunch) {
//        [self createFirstLaunchEvents];
        [self addALotOfRandomEvents];

    } else if ([self needToMigrateFromCoreData]) {
        [self migrateFromCoreData];

    }
}

#pragma mark - First Launch Events

+ (void)addALotOfRandomEvents {
    static NSInteger count = 500;
    NSMutableArray *events = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; ++i) {
        AEEvent *event = [AEEvent new];
        event.title = [NSString stringWithFormat:@"Random Event #%d", i];

        UInt32 range = 1000000000;
        NSTimeInterval interval = (range / 2) - arc4random_uniform(range);
        event.date = [NSDate dateWithTimeIntervalSinceNow:interval];
        [events addObject:event];
    }

    [RLMObject ae_setupAutoincrementForProperties:@[ @"id", @"order" ] onObjects:events];

    [[RLMRealm defaultRealm] transactionWithBlock:^{
        [[RLMRealm defaultRealm] addObjects:events];
    }];
}

+ (NSDate *)nextChristmassDate {
    NSCalendar *georgian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [georgian components:NSCalendarUnitYear
                                               fromDate:[NSDate date]];
    components.day = 25;
    components.month = 12;
    NSDate *date = [georgian dateFromComponents:components];

    if ([date compare:[NSDate date]] == NSOrderedAscending) {
        components.year++;
        date = [georgian dateFromComponents:components];
    }

    return date;
}

+ (NSDate *)nextNewYearDate {
    NSCalendar *georgian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [georgian components:NSCalendarUnitYear
                                               fromDate:[NSDate date]];
    components.day = 1;
    components.month = 1;
    components.year++;
    NSDate *date = [georgian dateFromComponents:components];
    return date;
}

+ (NSDate *)iphoneReleaseDate {
    NSCalendar *georgian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = 29;
    components.month = 6;
    components.year = 2007;
    NSDate *date = [georgian dateFromComponents:components];
    return date;
}

+ (void)createFirstLaunchEvents {
    AEEvent *christmas = [AEEvent new];
    christmas.title = NSLocalizedString(@"Christmas", @"event title");
    christmas.date = [self nextChristmassDate];
    christmas.color = [AEItemColor colorWithIdentifier:@"indigo"];

    AEEvent *iphone = [AEEvent new];
    iphone.id = christmas.id + 1;
    iphone.order = christmas.order + 1;
    iphone.title = NSLocalizedString(@"First iPhone Release", @"event title");
    iphone.date = [self nextChristmassDate];
    iphone.color = [AEItemColor colorWithIdentifier:@"violet"];

    NSArray *events = @[ christmas, iphone ];
    [RLMObject ae_setupAutoincrementForProperties:@[ @"id", @"order" ] onObjects:events];

    [[RLMRealm defaultRealm] transactionWithBlock:^{
        [[RLMRealm defaultRealm] addObjects:events];
    }];
}

#pragma mark - Core Data Migration

+ (BOOL)needToMigrateFromCoreData {
    return NO;
}

+ (void)migrateFromCoreData {
    
}

@end
