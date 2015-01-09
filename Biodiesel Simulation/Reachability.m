//
//  Reachability.m
//  Biodiesel Simulation
//
//  Created by Kyle Zawacki on 1/8/15.
//  Copyright (c) 2015 University Of Wisconsin Parkside. All rights reserved.
//

#import "Reachability.h"

@implementation Reachability

+ (BOOL)connectedToInternet
{
    NSURL *url=[NSURL URLWithString:@"http://www.google.com"];
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"HEAD"];
    NSHTTPURLResponse *response;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: NULL];
    
    return ([response statusCode]==200)?YES:NO;
}

+ (UIAlertController*)noInternetAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Internet!" message:@"You are not connected to the internet!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:action];
    
    return alert;
}

@end
