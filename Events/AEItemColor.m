//
//  AEItemColor.m
//  Events
//
//  Created by Lebedev Aleksey on 13/6/14.
//  Copyright (c) 2014 Aleksey Lebedev. All rights reserved.
//

#import "AEItemColor.h"

@interface AEItemColor ()

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UIColor *startColor;
@property (nonatomic, strong) UIColor *endColor;

@end

@implementation AEItemColor

+ (NSArray*)availableColors {
  static NSArray *availableColors = nil;
  if (!availableColors) {
      availableColors = @[
          [AEItemColor colorWithIdentifier:@"blue" name:@"Blue"
                                startColor:[UIColor blueColor] endColor:[UIColor whiteColor]],
          [AEItemColor colorWithIdentifier:@"red" name:@"Red"
                                startColor:[UIColor redColor] endColor:[UIColor whiteColor]],
          [AEItemColor colorWithIdentifier:@"gray" name:@"Gray"
                                startColor:[UIColor grayColor] endColor:[UIColor whiteColor]]
      ];
  }
  return availableColors;
}

+ (AEItemColor*)randomColor {
  NSInteger randomIndex = arc4random() % [[self availableColors] count];
  return [self availableColors][randomIndex];
}

+ (AEItemColor*)colorWithIdentifier:(NSString*)identifier {
  static NSDictionary *itemColorsByIdentifier = nil;
  if (!itemColorsByIdentifier) {
    itemColorsByIdentifier =
        [NSDictionary dictionaryWithObjects:[self availableColors]
                                    forKeys:[[self availableColors] valueForKeyPath:@"identifier"]];
  }
  return itemColorsByIdentifier[identifier];
}

+ (AEItemColor*)colorWithIdentifier:(NSString*)identifier name:(NSString*)name
                         startColor:(UIColor*)startColor endColor:(UIColor*)endColor {
  AEItemColor *instance = [AEItemColor new];
  instance.identifier = identifier;
  instance.name = name;
  instance.startColor = startColor;
  instance.endColor = endColor;
  return instance;
}

@end
