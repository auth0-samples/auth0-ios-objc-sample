# User Profile 

[Full Tutorial](https://auth0.com/docs/quickstart/native/ios-objc/04-user-profile)

This sample demonstrates how to retrieve an Auth0 user's profile and how to update it using the [Auth0.swift](https://github.com/auth0/Auth0.swift) toolkit. Session management strategies implemented in this project are explained in the [session handling sample project](/03-Session-Handling).

The idea of this sample is to show how to modify and update that additional data, which corresponds to the `userMetadata` dictionary in the `A0UserProfile` class.

Start by renaming the `Auth0.plist.example` file in the `Auth0Sample` directory to `Auth0.plist` and provide the `CLIENT_ID` and `DOMAIN` for your app.

#### Important Snippets

##### 1. Update the user metadata

In `EditProfileViewController.m` we put all the user's input data into a `NSDictionary` in `fieldsToDictionary`:

```objective-c
- (NSDictionary*)fieldsToDictionary {
    return @{@"first_name": self.userFirstNameField.text,
             @"last_name": self.userLastNameField.text,
             @"country": self.userCountryField.text};
}
```

When the user presses the save button, we send the dictionary of user metadata using the `patchUserWithIdentifier` call. Once we have the callback return and there was no error, we send the Navigation Controller to the previous view in the pile and send it the updated profile instance. 

```objective-c
- (IBAction)saveProfile:(id)sender {

    A0SimpleKeychain *keychain = [[A0SimpleKeychain alloc] initWithService:@"Auth0"];
    
    if (![keychain stringForKey:@"id_token"]) {
        return;
    }
    
    NSDictionary *profileMetadata = [self fieldsToDictionary];

    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];

    NSURL *domain = [NSURL a0_URLWithDomain: [infoDict objectForKey:@"Auth0Domain"]];

    A0ManagementAPI *authAPI = [[A0ManagementAPI alloc] initWithToken:[keychain stringForKey:@"id_token"] url:domain];
    
    [authAPI patchUserWithIdentifier:self.userProfile.userId userMetadata:profileMetadata callback:^(NSError * _Nullable error, NSDictionary<NSString *,id> * _Nullable data) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (error) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                [self presentViewController:alert animated:true completion:nil];
            } else {
                self.userProfile = [[A0UserProfile alloc] initWithDictionary:data];
                [self.navigationController popViewControllerAnimated:YES];
                UIViewController *controller = [self.navigationController topViewController];
                if([controller respondsToSelector:@selector(setUserProfile:)]){
                    [controller performSelector:@selector(setUserProfile:) withObject:self.userProfile afterDelay:0];
                }
            }
        });
    }];
}
```

Another option, not shown in this sample project, would be to have an external `SessionKeeper` class where we take from and store the profile instance so we don't have to pass it on between view controllers.
