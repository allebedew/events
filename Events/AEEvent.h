//
//  Entity.h
//  Events
//
//  Created by Lebedev Aleksey on 30/3/14.
//  Copyright (c) 2014 Aleksey Lebedev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@class AEItemColor;

@interface AEEvent : RLMObject

#pragma mark - Realm

@property NSInteger id;
@property NSString *title;
@property NSInteger order;
@property NSDate *date;
@property NSString *colorIdentifier;

#pragma mark - Custom Properties

@property (nonatomic, readonly) NSString *dateString;
@property (nonatomic, readonly) NSDateComponents *intervalDateComponents;
@property (nonatomic, readonly) NSString *intervalString;
@property (nonatomic, strong) AEItemColor *color;

@end
