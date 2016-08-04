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

#import <Lock/Lock.h>
#import "HomeViewController.h"
#import "ProfileViewController.h"
#import "SimpleKeychain.h"
#import "UIAlertController+LoadingAlert.h"

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIAlertController *loadingAlert = [UIAlertController loadingAlert];
    [loadingAlert presentInViewController:self];
    
    [self loadCredentialsSuccess:^(A0UserProfile * _Nonnull profile) {
        [loadingAlert dismiss];
        [self performSegueWithIdentifier:@"ShowProfile" sender:profile];
    } failure:^(NSError * _Nonnull error) {
        A0SimpleKeychain *keychain = [[A0SimpleKeychain alloc] initWithService:@"Auth0"];
        [keychain clearAll];
        [loadingAlert dismiss];
    }];
}

- (void)loadCredentialsSuccess:(A0APIClientUserProfileSuccess)success
                       failure:(A0APIClientError)failure {
    
    A0SimpleKeychain *keychain = [[A0SimpleKeychain alloc] initWithService:@"Auth0"];
    
    if ([keychain stringForKey:@"id_token"]) {
        A0Lock *lock = [A0Lock sharedLock];
        [lock.apiClient fetchUserProfileWithIdToken:[keychain stringForKey:@"id_token"] success:success failure:^(NSError * _Nonnull error) {
            [lock.apiClient fetchNewIdTokenWithRefreshToken:[keychain stringForKey:@"refresh_token"] parameters:nil success:^(A0Token * _Nonnull token) {
                [self saveCredentials:token];
                [self loadCredentialsSuccess:success failure:failure];
            } failure:failure];
        }];
    } else {
        failure([[NSError alloc] initWithDomain:@"NoError" code:0 userInfo:nil]);
    }
}

- (void)saveCredentials:(A0Token *)token {
    A0SimpleKeychain *keychain = [[A0SimpleKeychain alloc] initWithService:@"Auth0"];
    [keychain setString:token.idToken forKey:@"id_token"];
    [keychain setString:token.refreshToken forKey:@"refresh_token"];
}

- (IBAction)showLoginController:(id)sender {
    A0Lock *lock = [A0Lock sharedLock];
    
    A0LockViewController *controller = [lock newLockViewController];
    controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
        // Do something with token & profile. e.g.: save them.
        // And dismiss the ViewController
        [self saveCredentials:token];
        [self dismissViewControllerAnimated:YES completion:nil];
        [self performSegueWithIdentifier:@"ShowProfile" sender:profile];
    };
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowProfile"]) {
        ProfileViewController *controller = segue.destinationViewController;
        controller.userProfile = sender;
    }
}

- (IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue {
    A0SimpleKeychain *keychain = [[A0SimpleKeychain alloc] initWithService:@"Auth0"];
    [keychain clearAll];
}

@end
