//
//  ProfileViewController.m
//  Auth0Sample
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
#import <Lock/Lock.h>
#import "Auth0-Swift.h"
#import "SimpleKeychain.h"
#import "ProfileViewController.h"
#import "EditProfileViewController.h"

@interface ProfileViewController()

@property (nonatomic, strong) IBOutlet UIImageView* avatarImageView;
@property (nonatomic, strong) IBOutlet UILabel* welcomeLabel;
@property (nonatomic, strong) IBOutlet UIButton* linkFacebookButton;
@property (nonatomic, strong) IBOutlet UIButton* linkTwitterButton;
@property (nonatomic, strong) IBOutlet UIButton* linkGoogleButton;
@end

@implementation ProfileViewController

- (void) viewDidLoad{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;

    self.welcomeLabel.text = [NSString stringWithFormat:@"Welcome, %@", self.userProfile.name];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:self.userProfile.picture completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.avatarImageView.image = [UIImage imageWithData:data];
        });

    }] resume];
    
    for (A0UserIdentity* identity in self.userProfile.identities) {
        if([identity.connection isEqualToString:@"facebook"]) {
            [self.linkFacebookButton setHighlighted:YES];
        } else if ([identity.connection isEqualToString:@"google-oauth2"]) {
            [self.linkGoogleButton setHighlighted:YES];
        } else if ([identity.connection isEqualToString:@"twitter"]) {
            [self.linkTwitterButton setHighlighted:YES];
        }
    }
}

- (IBAction)linkAccount:(id)sender
{
    NSString* connection;
    
    if(sender == self.linkGoogleButton) {
        connection = @"google-oauth2";
    } else if (sender == self.linkTwitterButton) {
        connection = @"twitter";
    } else if (sender == self.linkFacebookButton) {
        connection = @"facebook";
    } else {
        return;
    }
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSURL *domain =  [NSURL a0_URLWithDomain: [infoDict objectForKey:@"Auth0Domain"]];
    NSString *clientId = [infoDict objectForKey:@"Auth0ClientId"];
    

    A0WebAuth *webAuth = [[A0WebAuth alloc] initWithClientId:clientId url:domain];
    
    [webAuth setConnection:connection];
    
    [webAuth start:^(NSError * _Nullable error, A0Credentials * _Nullable credentials) {
       if(error) {
           NSLog(error.localizedDescription);
       }
       else {
           A0SimpleKeychain* keychain = [[A0SimpleKeychain alloc] initWithService:@"Auth0"];

           A0ManagementAPI *authApi = [[A0ManagementAPI alloc] initWithToken:[keychain stringForKey:@"id_token"] url:domain];
           
           [authApi linkUserWithIdentifier:self.userProfile.userId  withUserUsingToken: credentials.idToken callback:^(NSError * _Nullable error, NSArray<NSDictionary<NSString *,id> *> * _Nullable payload) {
               
               if(error){
                   NSLog(error.localizedDescription);
               }
           }];
       }
    }];
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"EditUserSegue"]){
        if ([segue.destinationViewController isKindOfClass:[EditProfileViewController class]]){
            EditProfileViewController* destination = segue.destinationViewController;
            
            destination.userProfile = self.userProfile;
        }
    }
}

@end