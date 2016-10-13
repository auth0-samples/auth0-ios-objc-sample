//
// EditProfileViewController.m
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
#import <Lock/A0UserProfile.h>
#import "EditProfileViewController.h"
#import "SimpleKeychain.h"
#import "Auth0InfoHelper.h"
@import Auth0;

@interface EditProfileViewController()

@property (nonatomic, weak) IBOutlet UITextField *userEmailField;
@property (nonatomic, weak) IBOutlet UITextField *userFirstNameField;
@property (nonatomic, weak) IBOutlet UITextField *userLastNameField;
@property (nonatomic, weak) IBOutlet UITextField *userCountryField;

@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.userEmailField setText:self.userProfile.email];
    [self.userFirstNameField setText:[self.userProfile.userMetadata objectForKey:@"first_name"]];
    [self.userLastNameField setText:[self.userProfile.userMetadata objectForKey:@"last_name"]];
    [self.userCountryField setText:[self.userProfile.userMetadata objectForKey:@"country"]];
}

- (NSDictionary*)fieldsToDictionary {
    return @{@"first_name": self.userFirstNameField.text,
             @"last_name": self.userLastNameField.text,
             @"country": self.userCountryField.text};
}

- (IBAction)saveProfile:(id)sender {

    A0SimpleKeychain *keychain = [[A0SimpleKeychain alloc] initWithService:@"Auth0"];
    
    if (![keychain stringForKey:@"id_token"]) {
        return;
    }
    
    NSDictionary *profileMetadata = [self fieldsToDictionary];

    NSURL *domain = [Auth0InfoHelper Auth0Domain];

    A0ManagementAPI *authAPI = [[A0ManagementAPI alloc] initWithToken:[keychain stringForKey:@"id_token"] url:domain];
    
    [authAPI patchUserWithIdentifier:self.userProfile.userId userMetadata:profileMetadata callback:^(NSError * _Nullable error, NSDictionary<NSString *,id> * _Nullable data) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (error) {
                [self showErrorAlertWithMessage:error.localizedDescription];
            } else {
                self.userProfile = [[A0UserProfile alloc] initWithDictionary:data];
                [self.navigationController popViewControllerAnimated:YES];
                UIViewController *controller = [self.navigationController topViewController];
                if([controller respondsToSelector:@selector(setUserProfile:)]){
                    [controller performSelector:@selector(setUserProfile:) withObject:self.userProfile afterDelay:0];
                }
            }
        });
    }];
}

- (void)showErrorAlertWithMessage:(NSString*)message {
    dispatch_sync(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    });
}

@end
