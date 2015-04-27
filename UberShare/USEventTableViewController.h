//
//  USEventTableViewController.h
//  UberShare
//
//  Created by Johnson Ejezie on 4/25/15.
//  Copyright (c) 2015 Johnson Ejezie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTLCalendar.h"

@interface USEventTableViewController : UITableViewController

@property(nonatomic, strong)NSMutableArray* events;

@property(nonatomic, strong)GTLCalendarEvent* event;

@end
