//
//  RLMObject+AEHelpers.h
//  Events
//
//  Created by AL on 13/7/16.
//  Copyright © 2016 Aleksey Lebedev. All rights reserved.
//

#import <Realm/Realm.h>

@interface RLMObject (AEExtentions)

- (instancetype)ae_unmanagedCopy;

- (BOOL)ae_hasAllRequiredProperties;

@end
