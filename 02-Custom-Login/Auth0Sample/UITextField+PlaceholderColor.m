//
//  UITextField+PlaceholderColor.m
//  
//
//  Created by Sebastian Cancinos on 8/12/16.
//
//

#import "UITextField+PlaceholderColor.h"

@implementation UITextField (PlaceholderColor)

@dynamic placeholderTextColor;

- (void) setPlaceholderTextColor:(UIColor *)placeholderTextColor
{
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName: placeholderTextColor}];
}

@end
