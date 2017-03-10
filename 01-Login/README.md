# Login 

[Full Tutorial](https://auth0.com/docs/quickstart/native/ios-objc/01-login)

This sample project shows how to present a login dialog using the Lock widget interface. Once you log in, you're taken to a very basic profile screen, with some data about your user.

Start by renaming the `Auth0.plist.example` file in the `Auth0Sample` directory to `Auth0.plist` and provide the `CLIENT_ID` and `DOMAIN` for your app.

After that run `pod install` in the project folder.

#### Important Snippets

##### 1. Present the login widget

In `HomeViewController.m`:

```objective-c
- (IBAction)showLoginController:(id)sender {
    A0Lock *lock = [A0Lock sharedLock];
    
    A0LockViewController *controller = [lock newLockViewController];
    controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self performSegueWithIdentifier:@"ShowProfile" sender:profile];
    };
    
    [self presentViewController:controller animated:YES completion:nil];
}
```

##### 2. Pass the profile object

In this sample, the `profile` object is passed to the next screen through a variable, in the `prepareForSegue` method, as follows:

```objective-c
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"ShowProfile"]) {
        ProfileViewController *destViewController = segue.destinationViewController;
        destViewController.userProfile = sender;
    }
}
```

##### 3. Show basic profile data

In `ProfileViewController.m` we update the text label with the user's name, and load the profile image into the image view:

```objective-c
- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    self.welcomeLabel.text = [NSString stringWithFormat:@"Welcome, %@", self.userProfile.name];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:self.userProfile.picture completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.avatarImageView.image = [UIImage imageWithData:data];
        });
    }] resume];
}
```

