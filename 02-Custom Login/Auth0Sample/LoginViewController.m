//
//  LoginViewController.m
// Auth0Sample
//
// Copyright (c) 2016 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "LoginViewController.h"
#import "ProfileViewController.h"
#import "Auth0-Swift.h"
#import "Auth0InfoHelper.h"
#import "UIViewController_Dismiss.h"
#import "SignUpViewController.h"
#import "UIStoryboardSegueWithCompletion.h"

@interface LoginViewController()

@property (nonatomic, weak) IBOutlet UITextField *loginEmailText;
@property (nonatomic, weak) IBOutlet UITextField *loginPasswordText;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, weak) IBOutlet UIButton* loginButton;

@end

@implementation LoginViewController

- (void) loadUserWithCredentials:(A0Credentials*) credentials callback:(void (^ _Nonnull)(NSError * _Nullable, A0UserProfile * _Nullable))callback {
    
    A0AuthenticationAPI *authApi = [[A0AuthenticationAPI alloc] initWithClientId: [Auth0InfoHelper Auth0ClientID] url:[Auth0InfoHelper Auth0Domain]];

    [authApi userInfoWithToken:credentials.accessToken callback:callback];
}

- (IBAction)performLogin:(id)sender {
    
    A0AuthenticationAPI *authApi = [[A0AuthenticationAPI alloc] initWithClientId:[Auth0InfoHelper Auth0ClientID] url:[Auth0InfoHelper Auth0Domain]];
    
    [self.spinner startAnimating];
    [authApi loginWithUsername:self.loginEmailText.text password:self.loginPasswordText.text connection:@"Username-Password-Authentication" scope:@"openid" parameters:@{} callback:^(NSError * _Nullable error, A0Credentials * _Nullable credentials) {
        if(error) {
            NSLog(error.localizedDescription);
        } else {
            [self loadUserWithCredentials:credentials callback:^(NSError * _Nullable error, A0UserProfile * _Nullable profile) {
                
                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.spinner stopAnimating];

                    if(error) {
                        NSLog(error.localizedDescription);
                    } else {
                        [self performSegueWithIdentifier:@"ShowProfile" sender:profile];
                    }
                });
            }];
        }
    }];
}

- (IBAction)textFieldEditingChanged:(id)sender {
    self.loginButton.enabled = [self validateForm];
}

- (BOOL) validateForm {
    if(![self.loginPasswordText hasText]) {
        return NO;
    }
    
    if(!self.loginEmailText.hasText) {
        return NO;
    }
    
    return YES;
}

- (IBAction)unwindToLogin:(id)sender {
    if([sender isKindOfClass:[UIStoryboardSegueWithCompletion class]]) {
        UIStoryboardSegueWithCompletion* segue = sender;
        
        if([segue.sourceViewController isKindOfClass:[SignUpViewController class]]) {
            [self.spinner startAnimating];

            SignUpViewController* source = segue.sourceViewController;
            A0Credentials* credentials = source.retrievedCredentials;
            
            segue.completion = ^{
            [self loadUserWithCredentials:credentials callback:^(NSError * _Nullable error, A0UserProfile * _Nullable profile) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.spinner stopAnimating];
                        
                        if(error) {
                            NSLog(error.localizedDescription);
                        } else {
                            [self performSegueWithIdentifier:@"ShowProfile" sender:profile];
                        }
                    });
                }];
            };
        }
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"ShowProfile"]) {
        ProfileViewController* vc = segue.destinationViewController;
        vc.userProfile = sender;
    }
}

@end
