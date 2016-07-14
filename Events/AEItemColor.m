//
//  AEItemColor.m
//  Events
//
//  Created by Lebedev Aleksey on 13/6/14.
//  Copyright (c) 2014 Aleksey Lebedev. All rights reserved.
//

#import "AEItemColor.h"
#import "UIColor+AEExtentions.h"

@interface AEItemColor ()

@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UIColor *startColor;
@property (nonatomic, strong) UIColor *endColor;

@end

@implementation AEItemColor

+ (NSArray *)availableColors {
    static NSArray *availableColors;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        availableColors = @[
            [AEItemColor colorWithIdentifier:@"red" name:NSLocalizedString(@"Red", @"Title of the color")
                                  startColor:[UIColor ae_colorWithHue:0 sat:55 bright:90]],
            [AEItemColor colorWithIdentifier:@"orange" name:NSLocalizedString(@"Orange", @"Title of the color")
                                  startColor:[UIColor ae_colorWithHue:35 sat:85 bright:95]],
            [AEItemColor colorWithIdentifier:@"yellow" name:NSLocalizedString(@"Yellow", @"Title of the color")
                                  startColor:[UIColor ae_colorWithHue:53 sat:85 bright:85]],
            [AEItemColor colorWithIdentifier:@"green" name:NSLocalizedString(@"Green", @"Title of the color")
                                  startColor:[UIColor ae_colorWithHue:110 sat:60 bright:80]],
            [AEItemColor colorWithIdentifier:@"blue" name:NSLocalizedString(@"Blue", @"Title of the color")
                                  startColor:[UIColor ae_colorWithHue:200 sat:80 bright:90]],
            [AEItemColor colorWithIdentifier:@"indigo" name:NSLocalizedString(@"Indigo", @"Title of the color")
                                  startColor:[UIColor ae_colorWithHue:230 sat:65 bright:90]],
            [AEItemColor colorWithIdentifier:@"violet" name:NSLocalizedString(@"Violet", @"Title of the color")
                                  startColor:[UIColor ae_colorWithHue:280 sat:45 bright:85]],
            [AEItemColor colorWithIdentifier:@"gray" name:NSLocalizedString(@"Gray", @"Title of the color")
                                  startColor:[UIColor grayColor]]
        ];
    });
    return availableColors;
}

+ (AEItemColor *)colorWithIdentifier:(NSString*)identifier {
    static NSDictionary *itemColorsByIdentifier = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        itemColorsByIdentifier =
        [NSDictionary dictionaryWithObjects:[self availableColors]
                                    forKeys:[[self availableColors] valueForKeyPath:@"identifier"]];
    });
    return itemColorsByIdentifier[identifier];
}

+ (AEItemColor *)randomColor {
    NSInteger randomIndex = arc4random() % [[self availableColors] count];
    return [self availableColors][randomIndex];
}

+ (AEItemColor *)colorWithIdentifier:(NSString *)identifier name:(NSString *)name
                         startColor:(UIColor *)startColor {
    AEItemColor *instance = [AEItemColor new];
    instance.identifier = identifier;
    instance.name = name;
    instance.startColor = startColor;
    return instance;
}

@end
