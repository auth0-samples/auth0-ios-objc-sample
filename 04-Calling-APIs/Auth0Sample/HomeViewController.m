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
#import "ProfileViewController.h"
#import "Auth0Sample-Swift.h"
@import Auth0;

@interface HomeViewController ()

@end

@implementation HomeViewController

- (IBAction)showLoginController:(id)sender {

    NSString* identifier = nil; // Set to your API_IDENTIFIER value

    HybridAuth *auth = [[HybridAuth alloc] init];
    [auth showLoginWithScope:@"openid profile" connection:nil audience:identifier callback:^(NSError * _Nullable error, A0Credentials * _Nullable credentials) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            [auth userInfoWithAccessToken:[credentials accessToken] callback:^(NSError * _Nullable error, UserInfo * _Nullable profile) {
                if (error) {
                    NSLog(@"Error: %@", error.localizedDescription);
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self performSegueWithIdentifier:@"ShowProfile" sender:@{@"profile":profile, @"credentials":credentials}];
                    });
                }
            }];
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowProfile"]) {
        ProfileViewController *controller = segue.destinationViewController;
        controller.userProfile = sender[@"profile"];
        controller.credentials = sender[@"credentials"];
    }
}

- (IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue {
}


@end
