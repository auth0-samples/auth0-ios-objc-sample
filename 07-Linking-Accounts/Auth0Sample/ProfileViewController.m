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
#import "SimpleKeychain.h"
#import "ProfileViewController.h"
#import "UIAlertController+LoadingAlert.h"
#import "Auth0Sample-Swift.h"
@import Auth0;

@interface ProfileViewController()

@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;

@property (nonatomic, strong) IBOutlet UIButton *facebookLinkButton;
@property (nonatomic, strong) IBOutlet UIButton *facebookUnlinkButton;
@property (nonatomic, strong) IBOutlet UILabel *facebookNameLabel;

@property (nonatomic, strong) IBOutlet UIButton *twitterLinkButton;
@property (nonatomic, strong) IBOutlet UIButton *twitterUnlinkButton;
@property (nonatomic, strong) IBOutlet UILabel *twitterNameLabel;

@property (nonatomic, strong) IBOutlet UIButton *googleLinkButton;
@property (nonatomic, strong) IBOutlet UIButton *googleUnlinkButton;
@property (nonatomic, strong) IBOutlet UILabel *googleNameLabel;

@property (nonnull, strong) NSArray* identities;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    self.nameLabel.text = self.userProfile.name;
    
    [[[NSURLSession sharedSession] dataTaskWithURL:self.userProfile.pictureURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.avatarImageView.image = [UIImage imageWithData:data];
        });

    }] resume];
    
    self.identities = self.userProfile.identities;
    
    [self updateSocialAccounts];
}

- (void)updateSocialAccounts {
        [self.facebookLinkButton setEnabled:YES];
        [self.facebookNameLabel setHidden:YES];
        [self.facebookUnlinkButton setHidden:YES];

        [self.googleLinkButton setEnabled:YES];
        [self.googleNameLabel setHidden:YES];
        [self.googleUnlinkButton setHidden:YES];
        
        [self.twitterLinkButton setEnabled:YES];
        [self.twitterNameLabel setHidden:YES];
        [self.twitterUnlinkButton setHidden:YES];
        
        for (A0Identity *identity in self.identities) {
            if ([identity.connection isEqualToString:@"facebook"]) {
                [self.facebookLinkButton setEnabled:NO];
                [self.facebookNameLabel setHidden:NO];
                [self.facebookUnlinkButton setHidden:NO];
                [self.facebookNameLabel setText:identity.profileData[@"name"]];
            } else if ([identity.connection isEqualToString:@"google-oauth2"]) {
                [self.googleLinkButton setEnabled:NO];
                [self.googleNameLabel setHidden:NO];
                [self.googleUnlinkButton setHidden:NO];
                [self.googleNameLabel setText:identity.profileData[@"email"]];
            }
        }
}

- (void)updateIdentitiesWithArray:(NSArray*)jsonIdentities {
    NSArray *identities = [[NSArray alloc] init];
    for (NSDictionary *identity in jsonIdentities) {
        identities = [identities arrayByAddingObject:[[A0Identity alloc] initWithJson:identity]];
    }
    self.identities = identities;
    [self updateSocialAccounts];
}

- (IBAction)linkAccount:(id)sender {
    NSString *connection;
    if (sender == self.googleLinkButton) {
        connection = @"google-oauth2";
    } else if (sender == self.twitterLinkButton) {
        connection = @"twitter";
    } else if (sender == self.facebookLinkButton) {
        connection = @"facebook";
    } else {
        return;
    }

    HybridAuth *auth = [[HybridAuth alloc] init];
    A0SimpleKeychain *keychain = [[A0SimpleKeychain alloc] initWithService:@"Auth0"];
    
    [auth showLoginWithScope:@"openid profile" connection:connection callback:^(NSError * _Nullable error, A0Credentials * _Nullable credentials) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
             [self showErrorAlertWithMessage:error.localizedDescription];
                  });
        } else {
            [auth linkUserAccountWithIdToken:[keychain stringForKey:@"id_token"] userId:self.userProfile.id otherAccountToken: credentials.idToken callback:^(NSError * _Nullable error, NSArray<NSDictionary<NSString *,id> *> * _Nullable payload) {
                dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    [self showErrorAlertWithMessage:error.localizedDescription];
                } else {
                    [self updateIdentitiesWithArray:payload];
                }
                    });
            }];
        }

    }];
}

- (IBAction)unlinkAccount:(id)sender {
    NSString *connection;
    A0Identity *identity;
    
    if (sender == self.googleUnlinkButton) {
        connection = @"google-oauth2";
    } else if (sender == self.twitterUnlinkButton) {
        connection = @"twitter";
    } else if (sender == self.facebookUnlinkButton) {
        connection = @"facebook";
    } else {
        return;
    }
    
    for (A0Identity* userId in self.identities) {
        if([userId.connection isEqualToString:connection]) {
            identity = userId;
        }
    }
    
    if (!identity) {
        return;
    }
    
    UIAlertController *loadingAlert = [UIAlertController loadingAlert];
    [loadingAlert presentInViewController:self];
    HybridAuth *auth = [[HybridAuth alloc] init];
    A0SimpleKeychain* keychain = [[A0SimpleKeychain alloc] initWithService:@"Auth0"];
    
    [auth unlinkUserAccountWithIdToken:[keychain stringForKey:@"id_token"] userId:self.userProfile.id identity:identity  callback:^(NSError * _Nullable error, NSArray<NSDictionary<NSString *,id> *> * _Nullable payload) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [loadingAlert dismiss];
            if (error) {
                [self showErrorAlertWithMessage:error.localizedDescription];
            } else {
                [self updateIdentitiesWithArray:payload];
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
