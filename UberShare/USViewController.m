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
#import "GTLCalendar.h"
#import "USEventTableViewController.h"
@interface USViewController ()
@property (nonatomic, strong) NSDictionary* currentUser;
@property (nonatomic, strong) GTLServiceCalendar *calendarService;
@property(nonatomic, strong) NSMutableArray* eventArray;


@end

@implementation USViewController
@synthesize signInButton;

static NSString * const kFirebaseURL = @"https://ubershare.firebaseio.com/";
static NSString *const kKeychainItemName = @"Google Calendar Quickstart";
static NSString *const kClientID = @"862766779350-qp4p5drge9q30mgafjbpq2amoagikl8r.apps.googleusercontent.com";
static NSString *const kClientSecret = @"vkK-pb0H3OG5vc9CdpnOi6if";

- (void)viewDidLoad {
    [super viewDidLoad];
     self.eventArray = [[NSMutableArray alloc]init];
    // Do any additional setup after loading the view.
    [self authenticateWithGoogle];
    
}


- (void)authenticateWithGoogle {
    // use the Google+ SDK to get an OAuth token
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.clientID = kClientID;
    signIn.scopes =  @[kGTLAuthScopePlusUserinfoProfile, kGTLAuthScopePlusUserinfoEmail, kGTLAuthScopeCalendar];
    signIn.delegate = self;
    // authenticate will do a callback to finishedWithAuth:error:
    [signIn authenticate];
    // Initialize the Calendar service & load existing credentials from the keychain if available.
    self.calendarService = [[GTLServiceCalendar alloc] init];
    self.calendarService.authorizer =
    [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                          clientID:kClientID
                                                      clientSecret:kClientSecret];
}

- (void) finishedWithAuth:(GTMOAuth2Authentication *)auth
                    error:(NSError *)error {
    [self fetchEvents];
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
//                       [self fetchEvents];
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
- (void)fetchEvents {
    GTLQueryCalendar *query = [GTLQueryCalendar queryForEventsListWithCalendarId:@"primary"];
    query.maxResults = 10;
    query.timeMin = [GTLDateTime dateTimeWithDate:[NSDate date]
                                         timeZone:[NSTimeZone localTimeZone]];;
    query.singleEvents = @YES;
    query.orderBy = kGTLCalendarOrderByStartTime;
    NSMutableArray* holdArray = [NSMutableArray new];
    NSMutableDictionary* eventObj = [[NSMutableDictionary alloc]init];
    
    [self.calendarService executeQuery:query
                     completionHandler:^(GTLServiceTicket *ticket, GTLCalendarEvents *events, NSError *error) {
                         if (error == nil) {
                             NSLog(@"EVENT %@", events);
                             if (events.items.count == 0) {
                                 NSLog(@"No upcoming events found.");
                             } else {
                                 for (GTLCalendarEvent *event in events) {
                                     NSLog(@"event itself %@", event);
                                     eventObj[@"summary"] = event.summary;
                                     eventObj[@"startTime"] = event.start;
                                     eventObj[@"endTime"] = event.end;
                                     eventObj[@"date"] = event.created;
                                     if (event.location) {
                                         eventObj[@"location"] = event.location;
                                     }else {
                                        eventObj[@"location"] = @" ";
                                     }
                                     if (event.descriptionProperty) {
                                         eventObj[@"description"] = event.descriptionProperty;
                                     }else {
                                         eventObj[@"description"] = @"";
                                     }
                                     [holdArray addObject:event];
                                     NSLog(@"hold array %@",holdArray);
                                 }
                                 
                                 self.eventArray = holdArray;
                                 [self performSegueWithIdentifier:@"events" sender:nil];
                                  NSLog(@"event array %@", self.eventArray);
                             }
                         } else {
                             [self showAlert:@"Error" message:@"Unable to get calendar events."];
                         }
                     }];
    
}
// Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:title
                                       message:message
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
    [alert show];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"events"]) {
        USEventTableViewController *controller = (USEventTableViewController*)segue.destinationViewController;
        controller.events = self.eventArray;
    }
    
}


@end
