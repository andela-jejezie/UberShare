//
//  USViewController.h
//  UberShare
//
//  Created by Johnson Ejezie on 4/21/15.
//  Copyright (c) 2015 Johnson Ejezie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GooglePlus/GooglePlus.h>

@class GPPSignInButton;
@interface USViewController : UIViewController<GPPSignInDelegate, UIWebViewDelegate>

@property (retain, nonatomic) IBOutlet GPPSignInButton *signInButton;

@property (weak, nonatomic) IBOutlet UIButton *signUp;




@end
