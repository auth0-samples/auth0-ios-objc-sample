//
//  UIAlertController_LoadingAlert.h
//  Auth0Sample
//
//  Created by Sebastian Cancinos on 6/30/16.
//  Copyright © 2016 Auth0. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (LoadingAlert)

+ (UIAlertController*) loadingAlert;
- (void) presentInViewController:(UIViewController*) viewController;
- (void) dismiss;

@end
