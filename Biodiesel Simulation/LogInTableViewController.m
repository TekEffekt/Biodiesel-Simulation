//
//  LogInTableViewController.m
//  Biodiesel Simulation
//
//  Created by Kyle Zawacki on 11/2/14.
//  Copyright (c) 2014 UW Parkside. All rights reserved.
//

#import "LogInTableViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "Reachability.h"

@interface LogInTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property(strong, nonatomic) NSString *loginResult;

@end

@implementation LogInTableViewController

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1 && indexPath.row == 0)
    {
        [self checkIfLoginIsValid];
    }
    
    else if(indexPath.section == 2 && indexPath.row == 0)
    {
        [self performSegueWithIdentifier:@"To Register" sender:self];
    }
}

- (NSString *)md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

- (void)checkIfLoginIsValid
{
    if([Reachability connectedToInternet])
    {
        NSString *username = self.usernameTextField.text;
        NSString *password = self.passwordTextField.text;
        NSString *encrypt = [self md5:password];
        
        NSLog(@"Username: %@", username);
        NSLog(@"Password: %@", password);
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://cinnamon.cs.uwp.edu/biodiesel/app_userlogin.php?username=%@&password=%@", username, encrypt]];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                        completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                            if(!error)
                                                            {
                                                                NSString *stringResult = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:location] encoding:NSUTF8StringEncoding];
                                                                dispatch_async(dispatch_get_main_queue(), ^(void)
                                                                               {
                                                                                   self.loginResult = stringResult;
                                                                                   [self login:username];
                                                                               });
                                                            }
                                                        }];
        [task resume];
    } else
    {
        UIAlertController *alert = [Reachability noInternetAlert];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)login:(NSString*)username
{
    if([self.loginResult isEqualToString:@"Login Successful"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:username forKey:@"Logged In User"];
        
        UIAlertController *successfulAlert = [UIAlertController alertControllerWithTitle:@"Login Succesful" message:[NSString stringWithFormat:@"Welcome, %@!", username] preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){ [self performSegueWithIdentifier:@"From Login Button" sender:self]; }];
        
        [successfulAlert addAction:okAction];
        
        [self presentViewController:successfulAlert animated:YES completion:nil];
    } else
    {
        UIAlertController *failureAlert = [UIAlertController alertControllerWithTitle:@"Login Failed" message:@"Try a different input!" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        
        [failureAlert addAction:okAction];
        
        [self presentViewController:failureAlert animated:YES completion:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"From Login Button"])
    {
        UIViewController *destination = segue.destinationViewController;
        destination.navigationItem.hidesBackButton = YES;
    } else if([segue.identifier isEqualToString:@"From Skip Button"])
    {
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:@"Logged In User"];
    }
}

@end
