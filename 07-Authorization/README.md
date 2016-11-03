# Authorization 

[Full Tutorial](https://auth0.com/docs/quickstart/native/ios-objc/07-authorization)

Start by renaming the `Auth0.plist.example` file in the `Auth0Sample` directory to `Auth0.plist` and provide the `CLIENT_ID` and `DOMAIN` for your app.

#### Important Snippets

##### 1. Check the user role

Look at `ProfileViewController.m`:

```objective-c
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:@"AdminSegue"]) {
        if (![self.userProfile.appMetadata[@"roles"] containsObject:@"admin"]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Access denied" message:@"You do not have privileges to access the admin panel" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            return NO;
        }
    }
    return YES;
}
```
