//
//  YKViewController.h
//  Lesson4
//
//  Created by admin on 12.09.14.
//  Copyright (c) 2014 Yuri Kudrinetskiy. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;

@class YKViewController;

@protocol YKViewControllerDelegate <NSObject>
- (void)addYKViewController:(YKViewController *)controller didGetImage:(UIImage *)image description:(NSString *)description;
@end

@interface YKViewController : UIViewController

@property (weak, nonatomic) id <YKViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *getPhotosInfoButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)getPhotosInfo:(id)sender;

@end
