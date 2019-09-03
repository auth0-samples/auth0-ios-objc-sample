//
// HomeViewController.m
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

#import "HomeViewController.h"
#import "Auth0Sample-Swift.h"
@import Auth0;

@interface HomeViewController ()

@end

@implementation HomeViewController

static bool logged = false;

- (IBAction)showLoginController:(id)sender {
    HybridAuth *auth = [[HybridAuth alloc] init];

    if (!logged) {
        [auth showLoginWithScope:@"openid"
                      connection:nil callback:^(NSError * _Nullable error,
                                                A0Credentials * _Nullable credentials) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              if (error) {
                                  NSLog(@"Error: %@", error);
                              } else if (credentials) {
                                  [self showAlertWithMessage:[NSString stringWithFormat:@"Success, Access Token: %@", [credentials accessToken]]];
                                  [sender setTitle:@"Log out" forState:UIControlStateNormal];
                                  logged = true;
                              }
                          });
                      }];
        
    }else{
        [auth logOutUserWithCallback:^(BOOL response) {
            if(response){
                logged = false;
                [sender setTitle:@"Sign in" forState:UIControlStateNormal];
            }
            else{
                [self showAlertWithMessage:[NSString stringWithFormat:@"An error occurred"]];
            }
        }];

    }
}

- (void)showAlertWithMessage:(NSString*)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
