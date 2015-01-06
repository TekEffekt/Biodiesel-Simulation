//
//  RegisterTableViewController.m
//  Biodiesel Simulation
//
//  Created by Kyle Zawacki on 11/28/14.
//  Copyright (c) 2014 UW Parkside. All rights reserved.
//

#import "RegisterTableViewController.h"
#import <CommonCrypto/CommonDigest.h>

@interface RegisterTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmEmailTextField;

@property (weak, nonatomic) IBOutlet UISwitch *agreementSwitch;
@end

@implementation RegisterTableViewController

- (NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 5)
    {
        if(indexPath.row == 0)
        {
            [self registerUser];
        }
    }
}

- (void)registerUser
{
    if([self checkIfInputValid])
    {
        [self submitDataToServerToRegister];
    }
}

- (BOOL)checkIfInputValid
{
    BOOL inputValid = NO;
    if(![self.passwordTextField.text isEqual: @""] && ![self.emailTextField.text isEqual: @""] && ![self.usernameTextField.text  isEqual: @""])
    {
        if([self.passwordTextField.text isEqualToString:self.confirmPasswordTextField.text])
        {
            if([self.emailTextField.text isEqualToString:self.confirmEmailTextField.text])
            {
                if(self.agreementSwitch.on)
                {
                    inputValid = YES;
                } else
                {
                    [self errorHandlingMessages:@"Agreement Error"];
                }
            } else
            {
                [self errorHandlingMessages:@"Email Match Error"];
            }
        } else
        {
            [self errorHandlingMessages:@"Password Match Error"];
        }
    } else
    {
        [self errorHandlingMessages:@"Unfilled Fields Error"];
    }
    
    return inputValid;
}

- (void)submitDataToServerToRegister
{
    NSString *encrypt = [self md5:self.passwordTextField.text];
    NSString *confirmEncrypt = [self md5:self.confirmPasswordTextField.text];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://cinnamon.cs.uwp.edu/biodiesel/app_userregister.php?username=%@&password=%@&confirmpassword=%@&email=%@&confirmemail=%@",self.usernameTextField.text ,encrypt , confirmEncrypt, self.emailTextField.text,self.confirmEmailTextField.text]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration: configuration];
    NSURLSessionTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if(!error)
        {
            NSString *stringResult = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:location] encoding:NSUTF8StringEncoding];
            dispatch_async(dispatch_get_main_queue(), ^(void)
                           {
                               NSLog(@"%@", stringResult);
                               [self serverResponded:stringResult];
                           });
        }
    }];
    [task resume];
}

- (void)serverResponded:(NSString*)response
{
    if([response rangeOfString:@"UserName already in used."].location != NSNotFound) //yeah that's the server's response
    {
        [self errorHandlingMessages:@"Username Taken Error"];
    } else if([response rangeOfString:@"Successful"].location != NSNotFound)
    {
        [[NSUserDefaults standardUserDefaults] setValue:self.usernameTextField.text forKey:@"Logged In User"];
        
        [self displaySuccessMessage];
    } else
    {
        [self errorHandlingMessages:@"Default Error"];
    }
}

- (void)displaySuccessMessage
{
    UIAlertController *successAlert = [UIAlertController alertControllerWithTitle:@"Success" message:@"Your registration was succesful!" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSegueWithIdentifier:@"To Data Entry From Register" sender:self];
    }];
    
    [successAlert addAction:okAction];
    
    [self presentViewController:successAlert animated:YES completion:nil];
}

- (void)errorHandlingMessages:(NSString*)error
{
    NSString *errorMessage;
    
    if([error isEqualToString:@"Password Match Error"])
    {
        errorMessage = @"Your passwords do not match!";
    }
    else if([error isEqualToString:@"Email Match Error"])
    {
        errorMessage = @"Your emails do not match";
    } else if([error isEqualToString:@"Agreement Error"])
    {
        errorMessage = @"You have not accepted the agreement yet!";
    } else if([error isEqualToString:@"Unfilled Fields Error"])
    {
        errorMessage = @"Fill out all of the boxes!";
    } else if([error isEqualToString:@"Username Taken Error"])
    {
        errorMessage = @"This username is already taken!";
    } else if([error isEqualToString:@"Default Error"])
    {
        errorMessage = @"Oops, something went wrong! Check your inputs!";
    }
    
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    
    [errorAlert addAction:okAction];
    
    [self presentViewController:errorAlert animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"To Data Entry From Register"])
    {
        UIViewController *controller = segue.destinationViewController;
        controller.navigationItem.hidesBackButton = YES;
    }
}

@end
