//
// SignUpViewController.m
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
#import "SignUpViewController.h"
#import "ProfileViewController.h"
#import "UIViewController_Dismiss.h"
#import "UIView+roundCorners.h"
#import "UITextField+PlaceholderColor.h"
#import "UIColor+extraColors.h"
#import "Auth0Sample-Swift.h"
@import Auth0;

@interface SignUpViewController()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray* textFields;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray* actionButtons;

@end

@implementation SignUpViewController

- (void) viewDidLoad{

    [super viewDidLoad];

    for (UIButton* button in self.actionButtons) {
        [button setHasRoundLaterals:YES];
    }

    for (UITextField* field in self.textFields) {
        [field setPlaceholderTextColor:[UIColor lightVioletColor]];
    }
}

- (IBAction)textFieldEditingChanged:(id)sender {
    self.signUpButton.enabled = [self validateForm];
}

- (BOOL)validateForm {
    return self.emailTextField.hasText && self.passwordTextField.hasText;
}

- (IBAction)signUpAction:(id)sender {
    [self.spinner startAnimating];

    HybridAuth *auth = [[HybridAuth alloc] init];
    [auth signUpWithEmail:self.emailTextField.text
                 username:nil
                 password:self.passwordTextField.text
               connection:@"Username-Password-Authentication"
             userMetadata:@{@"first_name": self.firstNameTextField.text,
                            @"last_name": self.lastNameTextField.text}
                    scope:@"openid profile"
               parameters:@{}
                 callback:^(NSError * _Nullable error, A0Credentials * _Nullable credentials) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self.spinner stopAnimating];
                         if(error) {
                             [self showErrorAlertWithMessage:error.localizedDescription];
                         } else {
                             self.retrievedCredentials = credentials;
                             [self performSegueWithIdentifier:@"DismissSignUp" sender:nil];
                         }
                     });
                 }];
}

- (IBAction)socialLogin:(id)sender {

    NSString *connection;

    if (sender == self.twitterButton) {
        connection = @"twitter";
    } else if (sender == self.facebookButton) {
        connection = @"facebook";
    } else {
        return;
    }

    HybridAuth *auth = [[HybridAuth alloc] init];
    [auth showLoginWithConnection:connection scope:@"openid profile" callback:^(NSError * _Nullable error, A0Credentials * _Nullable credentials) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [self showErrorAlertWithMessage:error.localizedDescription];
            } else {
                [auth userInfoWithAccessToken:[credentials accessToken] callback:^(NSError * _Nullable error, A0Profile * _Nullable profile) {
                    if (error) {
                        NSLog(@"Error: %@", error.localizedDescription);
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.retrievedCredentials = credentials;
                            [self performSegueWithIdentifier:@"DismissSignUp" sender:nil];
                        });
                    }
                }];
            }
        });
    }];
}

- (void)showErrorAlertWithMessage:(NSString*)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
