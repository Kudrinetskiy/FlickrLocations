//
//  YKViewController.m
//  Lesson4
//
//  Created by admin on 12.09.14.
//  Copyright (c) 2014 Yuri Kudrinetskiy. All rights reserved.
//

#import "YKViewController.h"
#import "YKAnnotation.h"

@interface YKViewController ()
@property (nonatomic) NSArray * infoes;
@end

static NSString * const BaseURLString = @"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=90f769c05a5f121ea4e592ea0147b916&tags=chile&format=json&nojsoncallback=1&per_page=10&has_geo=1&extras=geo";

@implementation YKViewController

#pragma mark - IBAction

- (IBAction)getPhotoInfo:(id)sender
{
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:BaseURLString]];
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation, id responseObject) {
            self.infoes = ((NSDictionary *)responseObject)[@"photos"][@"photo"];
            NSLog(@"%@", [self.infoes description]);
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error retrieving photos" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
     }];
    
    [operation start];
    
    [self createAnnotations];
}

- (void)createAnnotations
{
    NSMutableArray * annotations = [NSMutableArray arrayWithCapacity:[self.infoes count]];

    for (NSDictionary * anInfo in self.infoes) {
        double latitude = [[anInfo objectForKey:@"latitude"] doubleValue];
        double longitude = [[anInfo objectForKey:@"longitude"] doubleValue];
        YKAnnotation * annotation = [YKAnnotation annotationWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude) title:anInfo[@"title"]];
        [annotations addObject:annotation];
    }
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:annotations];
    [self.mapView showAnnotations:annotations animated:YES];
    
}

#pragma mark - Private Methods

- (void)getInfo:(NSDictionary *)info
{
    NSString * requestString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=90f769c05a5f121ea4e592ea0147b916&format=json&nojsoncallback=1&photo_id=%@", info[@"id"]];
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestString]];
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"%@", [((NSDictionary *)responseObject) description]);
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error retrieving info" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [alertView show];
     }];
    
    [operation start];
}

#pragma mark - Map view delegate
     
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    NSString *annotationIdentifier = @"annotation";
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
    
    if (!annotationView){
        annotationView = [[MKAnnotationView alloc]initWithAnnotation:annotation
                                            reuseIdentifier:annotationIdentifier];
        annotationView.canShowCallout = YES;
    }
    else {
        annotationView.annotation = annotation;
    }
    
    annotationView.image = [UIImage imageNamed:@"label"];
    return annotationView;
}

@end
