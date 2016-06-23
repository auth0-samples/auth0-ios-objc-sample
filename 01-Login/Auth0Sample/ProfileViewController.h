//
//  ProfileViewController.h
//  Auth0Sample
//
//  Created by Sebastian Cancinos on 6/22/16.
//  Copyright © 2016 Auth0. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  A0UserProfile;

@interface ProfileViewController : UIViewController

@property (nonatomic, strong) A0UserProfile *userProfile;


@end
