recursivelyusing# Session Handling

[Full Tutorial](https://auth0.com/docs/quickstart/native/ios-objc/03-session-handling)

The idea of this sample is to keep the user logged after relaunching the app, to keep his profile up to date, and to clean everything up when he performs logout.

In this sample we keep state with the aid of the `SingleKeychain` library, which is, in a way, something similar to the well-known `NSUserDefaults`.

Start by renaming the `Auth0.plist.example` file in the `Auth0Sample` directory to `Auth0.plist` and provide the `CLIENT_ID` and `DOMAIN` for your app.

#### Important Snippets

##### 1. Check if a session already exists

Upon app's launch, you'd want to check if a user has already logged in, in order to take him straight to the app's content and prevent him from having to login again.

So, in `HomeViewController.m` as soon as the view controller loads, we try to load the credentials, in case of success the callback will dismiss the loading alert and show the next view, in case of failure, clean up the keychain of any possible invalid token and leave the user to login:

```objective-c
- (void)viewDidLoad {
    [super viewDidLoad];

    UIAlertController *loadingAlert = [UIAlertController loadingAlert];
    [loadingAlert presentInViewController:self];

    [self loadCredentialsSuccess:^(A0UserProfile * _Nonnull profile) {
        [loadingAlert dismiss];
        [self performSegueWithIdentifier:@"ShowProfile" sender:profile];
    } failure:^(NSError * _Nonnull error) {
        A0SimpleKeychain *keychain = [[A0SimpleKeychain alloc] initWithService:@"Auth0"];
        [keychain clearAll];
        [loadingAlert dismiss];
    }];
}

```

First of all, we check that the keychain effectively has an `id_token` stored, if not, it means the user isn't logged in and there is no session to maintain.
Then we'll get the user profile from the server using the stored token. On success we invoke the success callback and be our way. But if it fails, that's when it gets tricky, because it could fail for many number of reasons, if the token has expired, for example. But that doesn't mean we can't maintain the session. We can call `fetchNewIdTokenWithRefreshToken` using a refresh token and get a new, valid token. If this fails there's nothing to be done, but if it succeeds, it means we have a new token, we still need to get the profile.
So what do we do? We store the new token in the keychain and recursivelly call the method itself.
On this new iteration, the keychain will for sure have a token (we just stored it), it will call the server for the profile with the new token, and being a new token, it should succeed every time and continue. If this new token were to fail it will keep getting new tokens until one succeeds, or it crashes. Something that'd never happen, or in any case, would be a server side error.

```objective-c
- (void)loadCredentialsSuccess:(A0APIClientUserProfileSuccess)success
                       failure:(A0APIClientError)failure {

    A0SimpleKeychain* keychain = [[A0SimpleKeychain alloc] initWithService:@"Auth0"];

    if ([keychain stringForKey:@"id_token"]) {
        A0Lock *lock = [A0Lock sharedLock];
        [lock.apiClient fetchUserProfileWithIdToken:[keychain stringForKey:@"id_token"]
                                            success:success
                                            failure:^(NSError * _Nonnull error) {
            [lock.apiClient fetchNewIdTokenWithRefreshToken:[keychain stringForKey:@"refresh_token"] parameters:nil success:^(A0Token * _Nonnull token) {
                [self saveCredentials:token];
                [self loadCredentialsSuccess:success failure:failure];
            } failure:failure];
        }];
    } else {
        failure([[NSError alloc] initWithDomain:@"NoError" code:0 userInfo:nil]);
    }
}
```

##### 2. Getting that first token

So if there's no session to maintain, we'll use Lock to handle the Login process like we used on previous samples.
```objective-c
- (IBAction)showLoginController:(id)sender {
    A0Lock *lock = [A0Lock sharedLock];

    A0LockViewController *controller = [lock newLockViewController];
    controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
        // Do something with token & profile. e.g.: save them.
        // And dismiss the ViewController
        [self saveCredentials:token];
        [self dismissViewControllerAnimated:YES completion:nil];
        [self performSegueWithIdentifier:@"ShowProfile" sender:profile];
    };

    [self presentViewController:controller animated:YES completion:nil];
}
```

The only difference being that now, when the user logs in, we'll save the id token and refresh token for later use, using `A0SimpleKeychain`:

```objective-c
- (void)saveCredentials:(A0Token *)token {
    A0SimpleKeychain *keychain = [[A0SimpleKeychain alloc] initWithService:@"Auth0"];
    [keychain setString:token.idToken forKey:@"id_token"];
    [keychain setString:token.refreshToken forKey:@"refresh_token"];
}
```

##### 3. Log out

Once the user wants to close the session, we'll just clear the stored tokens from the keychain and send him back to `HomeViewController` via the unwind segue.

```objective-c
- (IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue {
    A0SimpleKeychain *keychain = [[A0SimpleKeychain alloc] initWithService:@"Auth0"];
    [keychain clearAll];
}
```
