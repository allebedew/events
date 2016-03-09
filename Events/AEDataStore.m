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

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadEventsFromFile];
    }
    return self;
}

- (NSString *)eventsFilePath {
    return @"";
}

- (void)loadEventsFromFile {
    NSData *eventsData = [NSData dataWithContentsOfFile:[self eventsFilePath]];
    self.mutableEvents = [NSKeyedUnarchiver unarchiveObjectWithData:eventsData];
}

- (NSArray<AEEvent *> *)events {
    return self.mutableEvents.copy;
}

@end
