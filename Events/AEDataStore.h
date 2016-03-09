//
//  AEDataStore.h
//  Events
//
//  Created by AL on 9/3/16.
//  Copyright © 2016 Aleksey Lebedev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AEEvent;

@interface AEDataStore : NSObject

+ (instancetype)sharedStore;

- (NSArray<AEEvent *> *)events;

@end
