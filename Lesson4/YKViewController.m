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
@property (nonatomic) NSMutableArray * thumbs;
@property (nonatomic) NSMutableArray * descriptions;
@property (nonatomic) NSMutableArray * annotations;
@property (nonatomic) NSMutableArray * fullSizeURLs;
@end

static NSString * const BaseURLString = @"https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=90f769c05a5f121ea4e592ea0147b916&format=json&nojsoncallback=1&per_page=10&has_geo=1&extras=geo";

@implementation YKViewController

#pragma mark - Tap getPhotosInfoButton

- (IBAction)getPhotosInfo:(id)sender
{
    [self.textField resignFirstResponder];
    NSString * requestString = [NSString stringWithFormat:@"%@&tags=%@", BaseURLString, self.textField.text];
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestString]];
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation, id responseObject) {
        self.thumbs = [NSMutableArray arrayWithCapacity:10];
        self.descriptions = [NSMutableArray arrayWithCapacity:10];
        self.fullSizeURLs = [NSMutableArray arrayWithCapacity:10];
        self.infoes = ((NSDictionary *)responseObject)[@"photos"][@"photo"];
        [self getPhotoFromEnumerator:[self.infoes objectEnumerator]];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error retrieving photo info" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [alertView show];
     }];
    
    [operation start];
}

#pragma mark - Private Methods

- (void)getPhotoFromEnumerator:(NSEnumerator *)enumerator
{
    NSDictionary * info = [enumerator nextObject];
    NSString * string = [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@", info[@"farm"], info[@"server"], info[@"id"], info[@"secret"]];
    NSString * requestString = [string stringByAppendingString:@"_s.jpg"];
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestString]];
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation, id responseObject) {
         [self.thumbs addObject:[UIImage imageWithData:(NSData *)responseObject]];
         [self.fullSizeURLs addObject:[string stringByAppendingString:@"_b.jpg"]];
         [self getPhotoDescByInfo:info fromEnumerator:enumerator];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error retrieving photos" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [alertView show];
     }];
    
    [operation start];
}

- (void)getPhotoDescByInfo:(NSDictionary *)info fromEnumerator:(NSEnumerator *)enumerator
{
    NSString * requestString = [NSString stringWithFormat:@"https://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=90f769c05a5f121ea4e592ea0147b916&format=json&nojsoncallback=1&photo_id=%@", info[@"id"]];
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:requestString]];
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];

    [operation setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation, id responseObject) {
         NSDictionary * json = (NSDictionary *)responseObject[@"photo"][@"location"];
         NSString * description = [NSString stringWithFormat:@"%@, %@", json[@"country"][@"_content"], json[@"county"][@"_content"]];
         [self.descriptions addObject:description];

         if ([self.descriptions count] < 10) {
             [self getPhotoFromEnumerator:enumerator];
         }
         else {
             [self createAnnotations];
         }
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error retrieving photo description" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [alertView show];
     }];
    
    [operation start];
}

- (void)createAnnotations
{
    [self.mapView removeAnnotations:self.annotations];
    self.annotations = [NSMutableArray arrayWithCapacity:[self.infoes count]];

    for (int i = 0; i < [self.infoes count]; i++) {
        double latitude = [[self.infoes[i] objectForKey:@"latitude"] doubleValue];
        double longitude = [[self.infoes[i] objectForKey:@"longitude"] doubleValue];
        YKAnnotation * annotation = [YKAnnotation
                            annotationWithCoordinate:CLLocationCoordinate2DMake(latitude, longitude)
                                               title:self.descriptions[i]
                                               image:self.thumbs[i]
                                         fullSizeURL:self.fullSizeURLs[i]];
        [self.annotations addObject:annotation];
    }
    
    [self.mapView addAnnotations:self.annotations];
    [self.mapView showAnnotations:self.annotations animated:YES];
}

- (void)getFullSizePhoto:(YKAnnotation *)annotation
{
    NSURLRequest * request = [NSURLRequest requestWithURL:
                              [NSURL URLWithString:annotation.fullSizeURL]];
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation, id responseObject) {
         UIImage * image = [UIImage imageWithData:(NSData *)responseObject];
         [self.delegate addYKViewController:self didGetImage:image description:annotation.title];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error retrieving photo" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
        annotationView.leftCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 58, 58)];
        YKAnnotation * ykAnnotation = (YKAnnotation *)annotation;
        imageView.image = ykAnnotation.image;
        [annotationView addSubview:imageView];
    }
    else {
        annotationView.annotation = annotation;
    }
    
    annotationView.image = [UIImage imageNamed:@"label"];
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    [self performSegueWithIdentifier:@"PhotoSegue" sender:(YKAnnotation *)view.annotation];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    [self.textField resignFirstResponder];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(YKAnnotation *)sender
{
    if ([segue.identifier isEqualToString:@"PhotoSegue"]) {
        self.delegate = segue.destinationViewController;
        [self getFullSizePhoto:sender];
    }
}

#pragma mark - Textfield delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
