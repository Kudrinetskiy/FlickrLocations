//
//  YKAnnotation.h
//  Lesson4
//
//  Created by admin on 13.09.14.
//  Copyright (c) 2014 Yuri Kudrinetskiy. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface YKAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;

+ (instancetype)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate title:(NSString *)title;

@end
