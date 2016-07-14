//
//  AEItemColor.h
//  Events
//
//  Created by Lebedev Aleksey on 13/6/14.
//  Copyright (c) 2014 Aleksey Lebedev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AEItemColor : NSObject

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) UIColor *startColor;
@property (nonatomic, readonly) UIColor *endColor;

+ (NSArray *)availableColors;
+ (AEItemColor *)randomColor;
+ (AEItemColor *)colorWithIdentifier:(NSString*)identifier;

@end
