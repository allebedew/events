//
//  Entity.h
//  Events
//
//  Created by Lebedev Aleksey on 30/3/14.
//  Copyright (c) 2014 Aleksey Lebedev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Entity : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * title;

@end
