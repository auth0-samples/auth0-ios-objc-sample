//
//  UIView+roundCorners.m
//  Auth0Sample
//
//  Created by Sebastian Cancinos on 8/12/16.
//  Copyright © 2016 Auth0. All rights reserved.
//

#import "UIView+roundCorners.h"

@implementation UIView (roundCorners)

- (BOOL) hasRoundLaterals
{
    return self.layer.cornerRadius > 0;
}

- (void) setHasRoundLaterals:(BOOL)hasRoundLaterals{
    if(hasRoundLaterals)
        self.layer.cornerRadius = self.frame.size.height / 2;
    else
        self.layer.cornerRadius = 0;
}

@end
