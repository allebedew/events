//
//  AEDataStore.m
//  Events
//
//  Created by AL on 9/3/16.
//  Copyright © 2016 Aleksey Lebedev. All rights reserved.
//

#import "AEDataStore.h"

@interface AEDataStore ()

@property (nonatomic, strong) NSMutableArray *mutableEvents;

@end

@implementation AEDataStore

+ (instancetype)sharedStore {
    static AEDataStore *sharedStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [AEDataStore new];
    });
    return sharedStore;
}

#pragma mark - Private

- (instancetype)init {
    self = [super init];
    if (self) {
        if ([self eventsDataFileExists]) {
            [self loadEventsFromEventsDataFile];
        }
    }
    return self;
}

- (NSString *)eventsDataFilePath {
    NSString *documentsPath = @"";
    return [documentsPath stringByAppendingPathComponent:@"events.data"];
}

- (BOOL)eventsDataFileExists {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self eventsDataFilePath]];
}

- (void)loadEventsFromEventsDataFile {
    NSData *eventsData = [NSData dataWithContentsOfFile:[self eventsDataFilePath]];
    if (eventsData) {
        self.mutableEvents = [NSKeyedUnarchiver unarchiveObjectWithData:eventsData];
    } else {
        self.mutableEvents = [NSMutableArray new];
    }
}

- (void)createStartupEvents {
    self.mutableEvents = [NSMutableArray array];
}

- (void)saveToEventsDataFile {
    NSData *eventsData = [NSKeyedArchiver archivedDataWithRootObject:self.mutableEvents];
    [eventsData writeToFile:[self eventsDataFilePath] atomically:YES];
}

#pragma mark - Public

- (NSArray<AEEvent *> *)events {
    return self.mutableEvents.copy;
}

- (void)addEvent:(AEEvent *)event {

}

- (void)removeEventAtIndex:(NSInteger)index {

}

- (void)replaceEventAtIndex:(NSInteger)index withEvent:(AEEvent *)event {

}

@end
