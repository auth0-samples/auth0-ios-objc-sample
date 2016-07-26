# Authorization 

The guts of this topic is actually found in the [full tutorial](https://auth0.com/docs/quickstart/native/ios-objc/07-authorization), where it's exposed how to configure a rule from the Auth0 management website.

However, this sample project does contain a snippet that might be of your interest.

#### Important Snippets

##### 1. Check the user role

Look at `ProfileViewController.m`:

```objc
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    
    if([identifier isEqualToString:@"AdminSegue"]){
        if(![self.userProfile.appMetadata[@"roles"] containsObject:@"admin"]){
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Access denied" message:@"You do not have privileges to access the admin panel" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
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
