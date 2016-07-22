# Linking Accounts 

- [Full Tutorial](https://auth0.com/docs/quickstart/native/ios-objc/05-linking-accounts)

This sample exposes how to manage accounts linking for an Auth0 user. 

We'll show one button for each third party authentication method, a label that shows how that system calls the user and an unlink button. In our Sample use Google, Twitter and Facebook. But you can set up your app to use a large number of methods you can set up on Auth0 dashboard

#### Important Snippets

##### 1. Retain all user's identities

User's identities (main account + linked accounts) can be found in the `identities` array from the `A0UserProfile` instance. We are storing the array as a property of the view controller, so we can later update it without having to update the whole profile instance.

To show the linked/unlinked status we call:
```objc
- (void) updateSocialAccounts
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.facebookLinkButton setEnabled:YES];
        [self.facebookNameLabel setHidden:YES];
        [self.facebookUnlinkButton setHidden:YES];

        [self.googleLinkButton setEnabled:YES];
        [self.googleNameLabel setHidden:YES];
        [self.googleUnlinkButton setHidden:YES];
        
        [self.twitterLinkButton setEnabled:YES];
        [self.twitterNameLabel setHidden:YES];
        [self.twitterUnlinkButton setHidden:YES];
        
        for (A0UserIdentity* identity in self.identities) {
            if([identity.connection isEqualToString:@"facebook"]) {
                [self.facebookLinkButton setEnabled:NO];
                [self.facebookNameLabel setHidden:NO];
                [self.facebookUnlinkButton setHidden:NO];
                [self.facebookNameLabel setText:identity.profileData[@"name"]];
            } else if ([identity.connection isEqualToString:@"google-oauth2"]) {
                [self.googleLinkButton setEnabled:NO];
                [self.googleNameLabel setHidden:NO];
                [self.googleUnlinkButton setHidden:NO];
                [self.googleNameLabel setText:identity.profileData[@"email"]];
            } else if ([identity.connection isEqualToString:@"twitter"]) {
                [self.twitterLinkButton setEnabled:NO];
                [self.twitterNameLabel setHidden:NO];
                [self.twitterUnlinkButton setHidden:NO];
                [self.twitterNameLabel setText:[NSString stringWithFormat:@"@%@",identity.profileData[@"screen_name"]]];
            }
        }
    });
}
```

Here we set all our view elements to an 'off' state and then we iterate over the profiles setting them as we find them.

##### 2. Link an account

First, the user is asked for the credentials of the account he wants to link. For this we will use the `A0WebAuth` class from `Auth0.Swift` toolkit, we set up the connection we want to link to, and we need to set up the scope to 'openid' in order to get the full token information we'll need to link the account. 
Another thing worth mentioning is that we'll need to set up a URL Type using our bundle identifier as the URL Scheme, and set up on the `AppDelegate` class

```objc
- (BOOL) application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options{
    return [A0WebAuth resumeAuthWithURL:url options:options];
}
```

Once the login callback returns, if everything went ok, we'll have the users credentials, we can do the actual linking of the profiles. 

```objc
- (IBAction)linkAccount:(id)sender
{
    NSString* connection;
    
    if(sender == self.googleLinkButton) {
        connection = @"google-oauth2";
    } else if (sender == self.twitterLinkButton) {
        connection = @"twitter";
    } else if (sender == self.facebookLinkButton) {
        connection = @"facebook";
    } else {
        return;
    }
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSURL *domain =  [NSURL a0_URLWithDomain: [infoDict objectForKey:@"Auth0Domain"]];
    NSString *clientId = [infoDict objectForKey:@"Auth0ClientId"];

    A0WebAuth *webAuth = [[A0WebAuth alloc] initWithClientId:clientId url:domain];
    
    [webAuth setConnection:connection];
    [webAuth setScope:@"openid"];
    
    [webAuth start:^(NSError * _Nullable error, A0Credentials * _Nullable credentials) {
       if(error) {
           [self showErrorAlertWithMessage:error.localizedDescription];
       } else {
           A0SimpleKeychain* keychain = [[A0SimpleKeychain alloc] initWithService:@"Auth0"];
           
           A0ManagementAPI *authApi = [[A0ManagementAPI alloc] initWithToken:[keychain stringForKey:@"id_token"] url:domain];
           
           [authApi linkUserWithIdentifier:self.userProfile.userId  withUserUsingToken: credentials.idToken callback:^(NSError * _Nullable error, NSArray<NSDictionary<NSString *,id> *> * _Nullable payload) {
               
               if(error){
                   [self showErrorAlertWithMessage:error.localizedDescription];
               } else {
                   [self updateIdentitiesWithArray: payload];
               }
           }];
       }
    }];
}
```

Notice that once the account is linked, the `updateIdentitiesWithArray:` method gets called, which will iterate the returned array of identites and parse them into `A0UserIdentity` instances. And then calling `updateSocialAccounts` we described in the first step.

##### 3. Unlink an account

The operation for unlinking the profiles is pretty similar. This time we'll already have the user identity, wich we'll need to find in the `identities` array by it's connection type. Then we call `unlinkUserWithIdentifier` to do the actual unlinking.

```objc
- (IBAction)unlinkAccount:(id)sender
{
    NSString* connection;
    A0UserIdentity* identity;
    
    if(sender == self.googleUnlinkButton) {
        connection = @"google-oauth2";
    } else if (sender == self.twitterUnlinkButton) {
        connection = @"twitter";
    } else if (sender == self.facebookUnlinkButton) {
        connection = @"facebook";
    } else {
        return;
    }
    
    for (A0UserIdentity* userId in self.identities) {
        if([userId.connection isEqualToString:connection]) {
            identity = userId;
        }
    }
    
    if(!identity)
        return;
    
    UIAlertController* loadingAlert = [UIAlertController loadingAlert];
    [loadingAlert presentInViewController:self];

    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSURL *domain =  [NSURL a0_URLWithDomain: [infoDict objectForKey:@"Auth0Domain"]];
    
    A0SimpleKeychain* keychain = [[A0SimpleKeychain alloc] initWithService:@"Auth0"];
    
    A0ManagementAPI *authApi = [[A0ManagementAPI alloc] initWithToken:[keychain stringForKey:@"id_token"] url:domain];
    
    [authApi unlinkUserWithIdentifier:identity.userId withProvider:identity.provider fromUserId:self.userProfile.userId callback:^(NSError * _Nullable error, NSArray<NSDictionary<NSString *,id> *> * _Nullable payload) {
        [loadingAlert dismiss];
        if(error){
            [self showErrorAlertWithMessage:error.localizedDescription];
        } else {
            [self updateIdentitiesWithArray: payload];
        }
    }];
}
```