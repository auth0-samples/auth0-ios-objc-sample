//
// LoginViewController.m
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

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "ProfileViewController.h"
#import "UIViewController_Dismiss.h"
#import "SignUpViewController.h"
#import "UIStoryboardSegueWithCompletion.h"

#import "UIView+roundCorners.h"
#import "UITextField+PlaceholderColor.h"
#import "UIColor+extraColors.h"
#import "Auth0Sample-Swift.h"
@import Auth0;

@interface LoginViewController()

@property (nonatomic, weak) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;
@property (nonatomic, weak) IBOutlet UIButton *facebookButton;
@property (nonatomic, weak) IBOutlet UIButton *twitterButton;

@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray* textFields;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray* actionButtons;

@end

@implementation LoginViewController

- (void) viewDidLoad{

    [super viewDidLoad];

    for (UIButton* button in self.actionButtons) {
        [button setHasRoundLaterals:YES];
    }

    for (UITextField* field in self.textFields) {
        [field setPlaceholderTextColor:[UIColor lightVioletColor]];
    }
}

- (IBAction)performLogin:(id)sender {

    HybridAuth *auth = [[HybridAuth alloc] init];

    [self.spinner startAnimating];
    [auth loginWithUsernameOrEmail:self.emailTextField.text
                          password:self.passwordTextField.text
                             realm:@"Username-Password-Authentication"
                          audience:nil
                             scope:@"openid profile"
                          callback:^(NSError * _Nullable error, A0Credentials * _Nullable credentials) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  if(error) {
                                      [self showErrorAlertWithMessage:error.localizedDescription];
                                  } else {
                                      [auth userInfoWithAccessToken:[credentials accessToken] callback:^(NSError * _Nullable error, UserInfo * _Nullable profile) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [self.spinner stopAnimating];
                                              if(error) {
                                                  [self showErrorAlertWithMessage: error.localizedDescription];
                                              } else {
                                                  [self performSegueWithIdentifier:@"ShowProfile" sender:profile];
                                              }
                                          });
                                      }];
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
    [auth showLoginWithScope:@"openid profile" connection:connection callback:^(NSError * _Nullable error, A0Credentials * _Nullable credentials) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                [self showErrorAlertWithMessage:error.localizedDescription];
            } else {
                [auth userInfoWithAccessToken:[credentials accessToken] callback:^(NSError * _Nullable error, UserInfo * _Nullable profile) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.spinner stopAnimating];
                        if(error) {
                            [self showErrorAlertWithMessage: error.localizedDescription];
                        } else {
                            [self performSegueWithIdentifier:@"ShowProfile" sender:profile];
                        }
                    });
                }];
            }
        });
    }];
}

- (IBAction)textFieldEditingChanged:(id)sender {
    self.loginButton.enabled = [self validateForm];
}

- (BOOL)validateForm {
    return self.emailTextField.hasText && self.passwordTextField.hasText;
}

- (IBAction)unwindToLogin:(UIStoryboardSegue*)sender {
    HybridAuth *auth = [[HybridAuth alloc] init];
    if([sender isKindOfClass:[UIStoryboardSegueWithCompletion class]]) {
        UIStoryboardSegueWithCompletion *segue = (UIStoryboardSegueWithCompletion*) sender;
        if([segue.sourceViewController isKindOfClass:[SignUpViewController class]]) {
            SignUpViewController *source = segue.sourceViewController;
            A0Credentials *credentials = source.retrievedCredentials;
            if(credentials){
                [self.spinner startAnimating];
                segue.completion = ^{
                    [auth userInfoWithAccessToken:[credentials accessToken] callback:^(NSError * _Nullable error, UserInfo * _Nullable profile) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.spinner stopAnimating];
                            if(error) {
                                [self showErrorAlertWithMessage: error.localizedDescription];
                            } else {
                                [self performSegueWithIdentifier:@"ShowProfile" sender:profile];
                            }
                        });
                    }];
                };
            }
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"ShowProfile"]) {
        ProfileViewController *controller = segue.destinationViewController;
        controller.userProfile = sender;
    }
}

- (void)showErrorAlertWithMessage:(NSString*)message {
    [self.spinner stopAnimating];

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
