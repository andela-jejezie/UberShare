//
//  USEventDetailViewController.h
//  UberShare
//
//  Created by Johnson Ejezie on 4/27/15.
//  Copyright (c) 2015 Johnson Ejezie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLCalendar.h"

@interface USEventDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;

@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;

@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;

@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@property(nonatomic, strong)GTLCalendarEvent* event;



@end
