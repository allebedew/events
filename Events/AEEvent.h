//
//  Entity.h
//  Events
//
//  Created by Lebedev Aleksey on 30/3/14.
//  Copyright (c) 2014 Aleksey Lebedev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AEItemColor;

@interface AEEvent : NSManagedObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSNumber *order;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSString *colorIdentifier;

@property (nonatomic, readonly) NSString *dateString;
@property (nonatomic, readonly) NSDateComponents *intervalDateComponents;
@property (nonatomic, readonly) NSString *intervalString;
@property (nonatomic, strong) AEItemColor *color;

+ (AEEvent*)eventWithTitle:(NSString*)title date:(NSDate*)date color:(AEItemColor*)color
                   context:(NSManagedObjectContext*)context insert:(BOOL)insert;

@end
