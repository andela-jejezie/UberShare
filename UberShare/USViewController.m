//
//  USViewController.m
//  UberShare
//
//  Created by Johnson Ejezie on 4/21/15.
//  Copyright (c) 2015 Johnson Ejezie. All rights reserved.
//

#import "USViewController.h"
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <Firebase/Firebase.h>

@interface USViewController ()
@property (nonatomic, strong) NSDictionary* currentUser;


@end

@implementation USViewController
@synthesize signInButton;

static NSString * const kFirebaseURL = @"https://ubershare.firebaseio.com/";
static NSString * const kGoogleClientID = @"862766779350-qp4p5drge9q30mgafjbpq2amoagikl8r.apps.googleusercontent.com";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self authenticateWithGoogle];
    
}


- (void)authenticateWithGoogle {
    // use the Google+ SDK to get an OAuth token
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.clientID = kGoogleClientID;
    signIn.scopes =  @[kGTLAuthScopePlusUserinfoProfile, kGTLAuthScopePlusUserinfoEmail];
    signIn.delegate = self;
    // authenticate will do a callback to finishedWithAuth:error:
    [signIn authenticate];
}
- (void) finishedWithAuth:(GTMOAuth2Authentication *)auth
                    error:(NSError *)error {
    if (error != nil) {
        // There was an error obtaining the Google+ OAuth token
    } else {
        NSLog(@">>>>>>>>>>> %@", auth);
        // We successfully obtained an OAuth token, authenticate on Firebase with it
        Firebase *ref = [[Firebase alloc] initWithUrl:kFirebaseURL];
        [ref authWithOAuthProvider:@"google" token:auth.accessToken
               withCompletionBlock:^(NSError *error, FAuthData *authData) {
                   if (error) {
                       // Error authenticating with Firebase with OAuth token
                   } else {
                       // User is now logged in!
                       NSLog(@"Successfully logged in! %@", authData.providerData[@"cachedUserProfile"]);
                       
                       NSDictionary* userDetails = @{
                                                     @"email" : authData.providerData[@"cachedUserProfile"][@"email"],
                                                     @"name" : authData.providerData[@"cachedUserProfile"][@"name"],
                                                     @"gender" : authData.providerData[@"cachedUserProfile"][@"gender"],
                                                     @"link" : authData.providerData[@"cachedUserProfile"][@"link"],
                                                     @"id" : authData.providerData[@"cachedUserProfile"][@"id"],
                                                     @"picture": authData.providerData[@"cachedUserProfile"][@"picture"],
                                                     };
                       Firebase *usersRef = [ref childByAppendingPath: @"users"];
                       Firebase *currentUserRef = [usersRef childByAppendingPath: authData.providerData[@"cachedUserProfile"][@"id"]];
                       [currentUserRef setValue:userDetails];
                       
                       _currentUser = userDetails;
                      
                   }
               }];
    }
}



@end
