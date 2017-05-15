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

    HybridLock *lock = [[HybridLock alloc] init];
    A0AuthenticationAPI *auth = [[A0AuthenticationAPI alloc] init];

    lock.onAuthenticationBlock = ^(A0Credentials *credentials) {
        [auth userInfoWithToken:[credentials accessToken] callback:^(NSError *error, A0Profile *profile) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (profile) {
                    NSLog(@"credentials: %@", [credentials accessToken]);
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [self performSegueWithIdentifier:@"ShowProfile" sender:profile];
                }
            });
        }];
    };

    [lock presentFrom:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"ShowProfile"]) {
        ProfileViewController *destViewController = segue.destinationViewController;
        destViewController.userProfile = sender;
    }
}

@end
