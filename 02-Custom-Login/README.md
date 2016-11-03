# Custom Login 

[Full Tutorial](https://auth0.com/docs/quickstart/native/ios-objc/02-custom-login)

This sample project shows how to make up a login and a sign up dialog by your own, by connecting to Auth0 services through the [Auth0.swift](https://github.com/auth0/Auth0.swift) toolkit.

You'll find two important view controllers here: The `LoginViewController` and the `SignUpViewController`, which contain text fields and buttons which are linked to actions that are described below.

Start by renaming the `Auth0.plist.example` file in the `Auth0Sample` directory to `Auth0.plist` and provide the `CLIENT_ID` and `DOMAIN` for your app.

#### Important Snippets

##### 1. Perform a Login

In `LoginViewController.m`:

```objective-c
- (IBAction)performLogin:(id)sender {
    
    A0AuthenticationAPI *authApi = [[A0AuthenticationAPI alloc] initWithClientId:[Auth0InfoHelper Auth0ClientID] url:[Auth0InfoHelper Auth0Domain]];
    
    [self.spinner startAnimating];
    [authApi loginWithUsername:self.loginEmailText.text password:self.loginPasswordText.text connection:@"Username-Password-Authentication" scope:@"openid" parameters:@{} callback:^(NSError * _Nullable error, A0Credentials * _Nullable credentials) {
        if(error) {
            NSLog(error.localizedDescription);
        } else {
            [self loadUserWithCredentials:credentials callback:^(NSError * _Nullable error, A0UserProfile * _Nullable profile) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.spinner stopAnimating];
                    if(error) {
                        NSLog(@"%@", error.localizedDescription);
                    } else {
                        [self performSegueWithIdentifier:@"ShowProfile" sender:profile];
                    }
                });
            }];
        }
    }];
}
```

##### 2. Pass the user profile object

The `A0UserProfile` instance is passed to show the profile in the next screen, that is to say, in the `ProfileViewController`.

So, in `LoginViewController.m`...

```objective-c
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"ShowProfile"]) {
        ProfileViewController *controller = segue.destinationViewController;
        controller.userProfile = sender;
    }
}
```

##### 3. Show basic profile info

In `ProfileViewController.m`:

```objective-c
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    self.welcomeLabel.text = [NSString stringWithFormat:@"Welcome, %@", self.userProfile.name];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:self.userProfile.pictureURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.avatarImageView.image = [UIImage imageWithData:data];
        });

    }] resume];
}
```

##### 4. Perform a Sign Up

In `SignUpViewController.m`:

```objective-c
- (IBAction)signUpAction:(id)sender {
    [self.spinner startAnimating];
    
    A0AuthenticationAPI *authApi = [[A0AuthenticationAPI alloc] initWithClientId:[Auth0InfoHelper Auth0ClientID] url:[Auth0InfoHelper Auth0Domain]];

    [authApi signUpWithEmail:self.emailTextField.text
                    username:nil
                    password:self.passwordTextField.text
                  connection:@"Username-Password-Authentication"
                userMetadata:nil
                       scope:@"openid"
                  parameters:nil
                    callback:^(NSError * _Nullable error, A0Credentials * _Nullable credentials) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.spinner stopAnimating];
                if(error) {
                    NSLog(error.localizedDescription);
                } else {
                    self.retrievedCredentials = credentials;
                    [self performSegueWithIdentifier:@"DismissSignUp" sender:nil];
                }
            });
    }];
}
```

Notice that the credentials are stored in the `retrievedCredentials` instance variable.

##### 5. Hook up Login and Sign Up navigation

Once someone has signed up, the `SignUpViewController` is dismissed, and the `LoginViewController` takes the control. Through an [unwind segue](https://www.youtube.com/watch?v=akmPXZ4hDuU), the `LoginViewController` automatically logs the user in with the credentials he's just got upon registering.

In `LoginViewController.m`:

```objective-c
- (IBAction)unwindToLogin:(id)sender {
    if([sender isKindOfClass:[UIStoryboardSegueWithCompletion class]]) {
        UIStoryboardSegueWithCompletion *segue = sender;
        
        if([segue.sourceViewController isKindOfClass:[SignUpViewController class]]) {
            [self.spinner startAnimating];

            SignUpViewController *source = segue.sourceViewController;
            A0Credentials *credentials = source.retrievedCredentials;
            
            segue.completion = ^{
            [self loadUserWithCredentials:credentials callback:^(NSError * _Nullable error, A0UserProfile * _Nullable profile) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.spinner stopAnimating];
                        if(error) {
                            NSLog(@"%@", error.localizedDescription);
                        } else {
                            [self performSegueWithIdentifier:@"ShowProfile" sender:profile];
                        }
                    });
                }];
            };
        }
    }
}
```
