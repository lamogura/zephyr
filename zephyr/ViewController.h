//
//  ViewController.h
//  zephyr
//
//  Created by mogura on 12/28/14.
//  Copyright (c) 2014 studystream. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HxMBLEConnectionManager.h"

@interface ViewController : UIViewController <HxMBLEManagerDelegate, UITableViewDataSource, UITableViewDelegate>

- (IBAction)startScanTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *heartRate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

