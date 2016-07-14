//
//  UIColor+AEExtentions.m
//  Events
//
//  Created by AL on 13/7/16.
//  Copyright © 2016 Aleksey Lebedev. All rights reserved.
//

#import "UIColor+AEExtentions.h"

@implementation UIColor (AEExtentions)

+ (UIColor *)ae_colorWithHue:(NSInteger)hue sat:(NSInteger)saturation bright:(NSInteger)brightnes {
    return [UIColor colorWithHue:hue / 360.0f saturation:saturation / 100.0f brightness:brightnes / 100.0f alpha:1.0f];
}

@end