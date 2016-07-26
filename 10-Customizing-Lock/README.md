# Customizing Lock 

- [Full Tutorial](https://auth0.com/docs/quickstart/native/ios-objc/10-customizing-lock)

This sample project exposes how to customize the [Lock](https://github.com/auth0/Lock.iOS-OSX) widget, by setting your own colors, icons, fonts, and more.

#### Important Snippets

##### 1. Create, customize and register your own theme

You'll find this snippet in the `AppDelegate.m` file:

```objc
- (void)customizeLockTheme {
    A0Theme *theme = [[A0Theme alloc] init];
    [theme registerImageWithName: @"badge"
                          bundle: [NSBundle mainBundle]
                          forKey: A0ThemeIconImageName];
    [theme registerColor: [UIColor yellowColor] forKey: A0ThemeTitleTextColor];
    [theme registerFont: [UIFont boldSystemFontOfSize: 14] forKey: A0ThemeTitleFont];
    [theme registerColor: [UIColor whiteColor] forKey: A0ThemeSeparatorTextColor];
    [theme registerColor: [UIColor yellowColor] forKey: A0ThemeTextFieldIconColor];
    [theme registerColor: [UIColor whiteColor] forKey: A0ThemeTextFieldPlaceholderTextColor];
    [theme registerColor: [UIColor yellowColor] forKey: A0ThemeTextFieldTextColor];
    [theme registerColor: [UIColor blackColor] forKey: A0ThemePrimaryButtonNormalColor];
    [theme registerColor: [UIColor yellowColor] forKey: A0ThemePrimaryButtonHighlightedColor];
    [theme registerFont: [UIFont boldSystemFontOfSize: 20] forKey: A0ThemePrimaryButtonFont];
    [theme registerColor: [UIColor redColor] forKey: A0ThemeSecondaryButtonBackgroundColor];
    [theme registerColor: [UIColor whiteColor] forKey: A0ThemeSecondaryButtonTextColor];
    [theme registerColor: [UIColor orangeColor] forKey: A0ThemeScreenBackgroundColor];
    [[A0Theme sharedInstance] registerTheme: theme];
}
```

