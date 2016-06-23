//
//  ProfileViewController.m
//  Auth0Sample
//
//  Created by Sebastian Cancinos on 6/22/16.
//  Copyright © 2016 Auth0. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Lock/Lock.h>
#import "ProfileViewController.h"

@interface ProfileViewController()

@property (nonatomic, strong) IBOutlet UIImageView* avatarImageView;
@property (nonatomic, strong) IBOutlet UILabel* welcomeLabel;

@end

@implementation ProfileViewController

- (void) viewDidLoad
{
    self.welcomeLabel.text = [NSString stringWithFormat:@"Welcome, %@", self.userProfile.name];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:self.userProfile.picture completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.avatarImageView.image = [UIImage imageWithData:data];
        });

    }] resume];
}

@end