//
//  YKViewController.h
//  Lesson4
//
//  Created by admin on 12.09.14.
//  Copyright (c) 2014 Yuri Kudrinetskiy. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;

@interface YKViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)getPhotoInfo:(id)sender;

@end
