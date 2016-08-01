//
//  UIAlertController_LoadingAlert.m
//  Auth0Sample
//
//  Created by Sebastian Cancinos on 6/30/16.
//  Copyright © 2016 Auth0. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIAlertController_LoadingAlert.h"

@implementation UIAlertController(LoadingAlert)

+ (UIAlertController*) loadingAlert{
    return [UIAlertController alertControllerWithTitle:@"Loading" message:@"Please, wait..." preferredStyle:UIAlertControllerStyleAlert];
}

- (void) presentInViewController:(UIViewController*) viewController{
    [viewController presentViewController:self animated:true completion:nil];
}

- (void) dismiss {
    [self dismissViewControllerAnimated:true completion:nil];
}

@end