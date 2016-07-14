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
#import <CoreData/CoreData.h>

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

+ (NSURL *)coreDataDBURL {
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return [documentsURL URLByAppendingPathComponent:@"Events.sqlite"];
}

+ (BOOL)needToMigrateFromCoreData {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self coreDataDBURL].path];
}

+ (void)migrateFromCoreData {
    NSLog(@"Starting CoreData migration");

    NSError *error = nil;
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Events" withExtension:@"momd"];
    NSManagedObjectModel *model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self coreDataDBURL] options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return;
    }
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    context.persistentStoreCoordinator = coordinator;

    NSFetchRequest *req = [NSFetchRequest fetchRequestWithEntityName:@"Event"];
    NSArray *results = [context executeFetchRequest:req error:&error];
    if (error) {
        NSLog(@"max order fetch error: %@", error);
        return;
    }

    NSMutableArray *events = [NSMutableArray array];
    for (NSManagedObject *coreDataObject in results) {
        AEEvent *event = [AEEvent new];
        event.title = [coreDataObject valueForKey:@"title"];
        event.date = [coreDataObject valueForKey:@"date"];
        event.colorIdentifier = [coreDataObject valueForKey:@"colorIdentifier"];
        event.order = [[coreDataObject valueForKey:@"order"] integerValue];
        [events addObject:event];
    }

    [RLMObject ae_setupAutoincrementForProperties:@[ @"id" ] onObjects:events];
    [[RLMRealm defaultRealm] transactionWithBlock:^{
        [[RLMRealm defaultRealm] addObjects:events];
    }];

    if (![coordinator removePersistentStore:coordinator.persistentStores.firstObject error:&error]) {
        NSLog(@"Error removing core data store: %@", error);
        return;
    }

    // Deleting core data files
    NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[self coreDataDBURL] URLByDeletingLastPathComponent].path error:nil];
    for (NSString *filename in filenames) {
        if ([filename hasPrefix:[[self coreDataDBURL] lastPathComponent]]) {
            NSURL *url = [[[self coreDataDBURL] URLByDeletingLastPathComponent] URLByAppendingPathComponent:filename];
            [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
            if (error) {
                NSLog(@"Error deleting file %@: %@", filename, error);
            }
        }
    }

    NSLog(@"Migration successful!");
}

@end
