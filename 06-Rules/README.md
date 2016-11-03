# Rules 

[Full Tutorial](https://auth0.com/docs/quickstart/native/ios-objc/06-rules)

This sample on itself does not contain really valuable content; however, the only piece of code that we can stand out is how to get the information added by the rule in the example from the tutorial.

Start by renaming the `Auth0.plist.example` file in the `Auth0Sample` directory to `Auth0.plist` and provide the `CLIENT_ID` and `DOMAIN` for your app.

#### Important Snippets

##### 1. Get the extra info added by a rule

Check out `ProfileViewController.m`:

```objective-c
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    NSString* welcomeText = [NSString stringWithFormat:@"Welcome, %@", self.userProfile.name];
    
    if (self.userProfile.extraInfo[@"country"]) {
        welcomeText = [welcomeText stringByAppendingFormat:@" from %@", self.userProfile.extraInfo[@"country"]];
    }
    
    self.welcomeLabel.text = welcomeText;
    
    [[[NSURLSession sharedSession] dataTaskWithURL:self.userProfile.picture completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.avatarImageView.image = [UIImage imageWithData:data];
        });

    }] resume];
}
```

Mainly this part:

```objective-c
if (self.userProfile.extraInfo[@"country"]) {
    welcomeText = [welcomeText stringByAppendingFormat:@" from %@", self.userProfile.extraInfo[@"country"]];
}
```

Notice the usage of the `extraInfo` dictionary there.