//
//  RLMObject+AEHelpers.m
//  Events
//
//  Created by AL on 13/7/16.
//  Copyright © 2016 Aleksey Lebedev. All rights reserved.
//

#import "RLMObject+AEExtentions.h"

@implementation RLMObject (AEExtentions)

- (instancetype)ae_unmanagedCopy {
    NSMutableDictionary *values = [NSMutableDictionary new];
    for (RLMProperty *property in self.objectSchema.properties) {
        switch (property.type) {
            case RLMPropertyTypeInt:
            case RLMPropertyTypeBool:
            case RLMPropertyTypeFloat:
            case RLMPropertyTypeDouble:
            case RLMPropertyTypeString:
            case RLMPropertyTypeData:
            case RLMPropertyTypeDate:
                values[property.name] = [self valueForKey:property.name];
                break;
            default:
                break;
        }
    }
    Class ObjectClass = NSClassFromString([[self class] className]);
    RLMObject *copy = [[ObjectClass alloc] initWithValue:values];
    return copy;
}

- (BOOL)ae_hasAllRequiredProperties {
    for (NSString *key in [[self class] requiredProperties]) {
        id value = [self valueForKey:key];
        if (value == nil) {
            return NO;
        } else if ([value isKindOfClass:[NSString class]] && ((NSString *)value).length == 0) {
            return NO;
        }
    }
    return YES;
}

@end
