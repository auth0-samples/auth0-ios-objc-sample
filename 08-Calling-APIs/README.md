# Calling APIs 

- [Full Tutorial](https://auth0.com/docs/quickstart/native/ios-objc/08-calling-apis)

The idea of this project is to perform authenticated requests by attaching the `idToken`, obtained upon login, into an authorization header.

This sample can be seen as a template where you'll have to set your own stuff in order to get it working. Pay attention to the snippets where you have to do that.

Also, you will need a server that accepts authenticated APIs with an endpoint capable of checking whether or not a request has been properly authenticated. You can use your own or [this nodeJS one](https://github.com/auth0-samples/auth0-angularjs2-systemjs-sample/tree/master/Server), whose setup is quite simple.

#### Important Snippets

##### 1. Call your API

The only important snippet you need to be aware of: making up an authenticathed request for your API!

Look at `ProfileViewController.m`:

```objc
-(void) callAPIAuthenticated: (BOOL) shouldAuthenticate {
    NSString* url =  @"change to your API URL";
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    if(shouldAuthenticate){
        NSString *token = self.token.idToken;
        [request addValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
    }
    
    [[[NSURLSession sharedSession] dataTaskWithRequest: request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSInteger statusCode = ((NSHTTPURLResponse*) response).statusCode;
        NSString* title;
        
        if(statusCode < 400) {
            title = @"Success!!";
        } else{
            title = @"Error";
        }
        
        NSString* message = [NSString stringWithFormat:@"Error Code: %li\n\nData:%@\n\nResponse:%@",(long)statusCode, (data == nil)?@"nil":@"(there is data)", response];
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* OKAction = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:nil];

        [alert addAction:OKAction];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alert animated:YES completion:nil];
        });
        
    }] resume];
}
```

These are the specific lines of code that you have to configure:

First, set your API url here:

```objc
NSString* url =  @"change to your API URL";
```

Then, pay attention to how the header is made up:

```objc
[request addValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
```

That string interpolation might vary depending on the standards that your API follows. The one showed in the sample corresponds to OAuth2 standards.

Also, this line is important:

```objc
NSString *token = self.token.idToken;
```

That specifies that the `idToken` is the token that you're using for authentication. You might want to choose using a different one (for example, the `accessToken`), it depends on how your API checks the authentication against Auth0.

> For further information on the authentication process, check out [the full documentation](https://auth0.com/docs/api/authentication).