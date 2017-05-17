//
// ProfileViewController.m
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
#import "ProfileViewController.h"
#import "Auth0Sample-Swift.h"
#import "SimpleKeychain.h"
@import Auth0;

@interface ProfileViewController()

@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet UILabel *welcomeLabel;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.hidesBackButton = YES;
    self.welcomeLabel.text = [NSString stringWithFormat:@"Welcome, %@", self.userProfile.name];

    [[[NSURLSession sharedSession] dataTaskWithURL:self.userProfile.pictureURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.avatarImageView.image = [UIImage imageWithData:data];
        });

    }] resume];
}

- (IBAction) checkAdminStatus:(id)sender {
    HybridAuth *auth = [[HybridAuth alloc] init];
    A0SimpleKeychain *keychain = [[A0SimpleKeychain alloc] initWithService:@"Auth0"];
    [auth userRolesWithIdToken:[keychain stringForKey:@"id_token"] userId:self.userProfile.id callback:^(NSError * _Nullable error, NSArray<NSString *> * _Nullable roles) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![roles containsObject:@"admin"]) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Access denied" message:@"You do not have privileges to access the admin panel" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {}];
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
            } else {
                [self performSegueWithIdentifier:@"AdminSegue" sender:nil];
            }
        });
    }];

}

@end
