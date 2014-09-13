//
//  YKAnnotation.m
//  Lesson4
//
//  Created by admin on 13.09.14.
//  Copyright (c) 2014 Yuri Kudrinetskiy. All rights reserved.
//

#import "YKAnnotation.h"
@interface YKAnnotation()
@property (nonatomic, readwrite, copy) NSString * title;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@end

@implementation YKAnnotation

@synthesize coordinate = _coordinate;

+ (instancetype)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title
{
    YKAnnotation * annotation = [[YKAnnotation alloc] init];
    annotation.coordinate = coordinate;
    annotation.title = [title copy];
    
    return annotation;
}

@end
