//
//  ViewController.m
//  zephyr
//
//  Created by mogura on 12/28/14.
//  Copyright (c) 2014 studystream. All rights reserved.
//

#import "ViewController.h"

#define StoppedMode 1
#define StartedMode 2

@interface ViewController ()
@property (nonatomic, strong) HxMBLEConnectionManager *hxManager;
@property (nonatomic, strong) CBPeripheral *hxDevice;
@property (nonatomic, strong) NSMutableArray *heartRates;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    self.heartRates = [NSMutableArray array];

    self.hxManager = [[HxMBLEConnectionManager alloc] initWithDeleget:self];
}

-(void) onUnspportedHarware:(NSString *) error {
    NSLog(@"");
}

-(void) onHxmDeviceDiscovered:(CBPeripheral *) device {
    if ([device.name containsString:@"Zephyr"]) {
        NSLog(@"Discovered Zephyr device: %@, connecting...", device.name);
        self.hxDevice = device;
        
        [self.hxManager stopScan];
        [self.hxManager connectToHxmDevice:device];
    }
}

-(void) onHxmDeviceConnected:(CBPeripheral *) device {
    NSLog(@"Connected Zephyr device: %@", device.name);
}

-(void) onHxmdeviceFialedToConnect:(CBPeripheral *)device error:(NSError *)error {
    NSLog(@"");
}

-(void) onHxmDeviceDisconnected:(CBPeripheral *)device error:(NSError *)error {
    NSLog(@"");
}

-(void) onPhysiologicalDataReceived:(PhysiologicalData *) data {
    NSString *time = [self.dateFormatter stringFromDate:[NSDate date]];
    
    DDLogInfo(@"%@: %d", time, data.heartRate);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.heartRate.text = [NSString stringWithFormat:@"%d", data.heartRate];
    });
    if (self.heartRate.hidden) self.heartRate.hidden = NO;
}

- (IBAction)startScanTapped:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == StoppedMode) {
        btn.tag = StartedMode;
        [btn setTitle:@"Stop Reading" forState:UIControlStateNormal];
        DDLogInfo(@"Reading Started");
        [self.hxManager startScan];
    }
    else {
        btn.tag = StoppedMode;
        [btn setTitle:@"Start Reading" forState:UIControlStateNormal];
        [self.hxManager disconnectHxmDevice];
        self.heartRate.hidden = YES;
        DDLogInfo(@"Reading Stopped");
    }
}
@end
