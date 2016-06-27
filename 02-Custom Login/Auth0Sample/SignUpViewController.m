//
//  SignUpViewController.m
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
#import "SignUpViewController.h"
#import "ProfileViewController.h"
#import "Auth0-Swift.h"
#import "Auth0InfoHelper.h"
#import "NSString_EmailValidation.h"
#import "UIViewController_Dismiss.h"

@interface SignUpViewController()

@property (weak, nonatomic) IBOutlet UITextField* emailTextField;
@property (weak, nonatomic) IBOutlet UITextField* passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton* signUpButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView* spinner;

@end

@implementation SignUpViewController

- (IBAction)textFieldEditingChanged:(id)sender
{
    self.signUpButton.enabled = [self validateForm];
    
}

- (BOOL) validateForm
{
    if(![self.passwordTextField hasText])
    {
        return NO;
    }
    
    if(!self.emailTextField.hasText)
    {
        return NO;
    }
    else
    {
        if(![self.emailTextField.text isValidEmail])
        {
            return NO;
        }
    }
    
    return YES;
    
}

- (IBAction)signUpAction:(id)sender
{
    [self.spinner startAnimating];
    
    A0AuthenticationAPI *authApi = [[A0AuthenticationAPI alloc] initWithClientId:[Auth0InfoHelper Auth0ClientID] url:[Auth0InfoHelper Auth0Domain]];

    [authApi signUpWithEmail:self.emailTextField.text
                    username:nil
                    password:self.passwordTextField.text
                  connection:@"Username-Password-Authentication"
                userMetadata:nil
                       scope:@"openid"
                  parameters:nil
                    callback:^(NSError * _Nullable error, A0Credentials * _Nullable credentials)
    {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.spinner stopAnimating];
                if(error)
                {
                    NSLog(error.localizedDescription);
                }
                else
                {
                    self.retrievedCredentials = credentials;
                    [self performSegueWithIdentifier:@"DismissSignUp" sender:nil];
                }
            });
    }];
}

@end