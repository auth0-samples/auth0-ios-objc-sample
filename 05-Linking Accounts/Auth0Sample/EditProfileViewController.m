//
//  EditProfileViewController.m
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
#import "EditProfileViewController.h"
#import <Lock/A0UserProfile.h>
#import "Auth0-Swift.h"
#import "SimpleKeychain.h"

@interface EditProfileViewController()

@property (nonatomic, weak) IBOutlet UITextField* userEmailField;
@property (nonatomic, weak) IBOutlet UITextField* userFirstNameField;
@property (nonatomic, weak) IBOutlet UITextField* userLastNameField;
@property (nonatomic, weak) IBOutlet UITextField* userCountryField;


@end

@implementation EditProfileViewController

- (void) viewDidLoad{
    [super viewDidLoad];
    
    [self.userEmailField setText:self.userProfile.email];
    [self.userFirstNameField setText:[self.userProfile.userMetadata objectForKey:@"firstName"]];
    [self.userLastNameField setText:[self.userProfile.userMetadata objectForKey:@"lastName"]];
    [self.userCountryField setText:[self.userProfile.userMetadata objectForKey:@"country"]];
}

- (NSDictionary*) fieldsToDictionary
{
    NSDictionary* dictionary = [[NSDictionary alloc]
                                initWithObjects:@[self.userFirstNameField.text,self.userLastNameField.text,self.userCountryField.text]
                                forKeys:@[@"firstName",@"lastName",@"country"]];
    
    return dictionary;
}

- (IBAction)saveProfile:(id)sender{

    A0SimpleKeychain* keychain = [[A0SimpleKeychain alloc] initWithService:@"Auth0"];
    
    if(![keychain stringForKey:@"id_token"]){
        return;
    }
    
    NSDictionary *profileMetadata = [self fieldsToDictionary];

    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];

    NSURL *domain =  [NSURL a0_URLWithDomain: [infoDict objectForKey:@"Auth0Domain"]];

    A0ManagementAPI *authApi = [[A0ManagementAPI alloc] initWithToken:[keychain stringForKey:@"id_token"] url:domain];
    
    [authApi patchUserWithIdentifier:self.userProfile.userId userMetadata:profileMetadata callback:^(NSError * _Nullable error, NSDictionary<NSString *,id> * _Nullable data) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            if(error) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                [self presentViewController:alert animated:true completion:nil];
            } else {
                
                self.userProfile = [[A0UserProfile alloc] initWithDictionary:data];
                [self.navigationController popViewControllerAnimated:YES];
                
                UIViewController* controller = [self.navigationController topViewController];
                
                if([controller respondsToSelector:@selector(setUserProfile:)]){
                    [controller performSelector:@selector(setUserProfile:) withObject:self.userProfile afterDelay:0];
                }
            }
        });
    }];
}

@end