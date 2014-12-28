//
//  ViewController.m
//  zephyr
//
//  Created by mogura on 12/28/14.
//  Copyright (c) 2014 studystream. All rights reserved.
//
@import MessageUI;

#import "ViewController.h"
#import "HeartRateSession.h"

#define StoppedMode 1
#define StartedMode 2

@interface ViewController () <MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) HxMBLEConnectionManager *hxManager;
@property (nonatomic, strong) CBPeripheral *hxDevice;
@property (nonatomic, strong) NSMutableArray *heartRates;
@property (nonatomic, strong) NSArray *sessions;
@property (nonatomic, strong) HeartRateSession *activeSession;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.heartRates = [NSMutableArray array];

    self.hxManager = [[HxMBLEConnectionManager alloc] initWithDeleget:self];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    [self refreshSessions];
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
    [SVProgressHUD showSuccessWithStatus:@"Connected!"];
}

-(void) onHxmdeviceFialedToConnect:(CBPeripheral *)device error:(NSError *)error {
    if (error) {
        NSLog(@"ERROR: %@", error.localizedDescription);
    }
}

-(void) onHxmDeviceDisconnected:(CBPeripheral *)device error:(NSError *)error {
    if (error) {
        NSLog(@"ERROR: %@", error.localizedDescription);
    }
}

-(void) onPhysiologicalDataReceived:(PhysiologicalData *) data {
    [UIApplication sharedApplication].applicationIconBadgeNumber = data.heartRate;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.heartRate.text = [NSString stringWithFormat:@"%d", data.heartRate];
    });
    if (self.heartRate.hidden) self.heartRate.hidden = NO;
    
    [self.activeSession logHeartRate:data.heartRate];
}

- (IBAction)startScanTapped:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == StoppedMode) {
        btn.tag = StartedMode;
        [btn setTitle:@"Stop Reading" forState:UIControlStateNormal];
        NSLog(@"Reading Started");
        [self.hxManager startScan];
        
        self.activeSession = [[HeartRateSession alloc] init];
        
        [SVProgressHUD show];
    }
    else {
        btn.tag = StoppedMode;
        [btn setTitle:@"Start Reading" forState:UIControlStateNormal];
        [self.hxManager disconnectHxmDevice];
        self.heartRate.hidden = YES;
        NSLog(@"Reading Stopped");
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        
        [self.activeSession endSession];
        self.activeSession = nil;
        [self refreshSessions];
    }
}

-(void)refreshSessions {
    NSString *sessionsPath = [HeartRateSession sessionsFolderPath];

    NSError *error;
    self.sessions = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sessionsPath error:&error];
    
    if (error) {
        NSLog(@"ERROR: %@", error.localizedDescription);
    }
    
    [self.tableView reloadData];
}

#pragma mark - TableView Datasource/Delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sessions.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    cell.textLabel.text = self.sessions[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self createEmailWithLogAtSessionPath:self.sessions[indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *sessionName = self.sessions[indexPath.row];
        NSString *path = [[HeartRateSession sessionsFolderPath] stringByAppendingPathComponent:sessionName];
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        if (error) {
            NSLog(@"ERROR: %@", error.localizedDescription);
        }
        [self refreshSessions];
    }
}
#pragma mark - MFMailComposeViewControllerDelegate

-(void)createEmailWithLogAtSessionPath:(NSString *)sessionPath {
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    
    [mailComposer setSubject:@"Heartrate Log"];

    NSArray *toRecipients = [NSArray arrayWithObject:@"xentropic@gmail.com"];
    [mailComposer setToRecipients:toRecipients];

    NSString *path = [[HeartRateSession sessionsFolderPath] stringByAppendingPathComponent:sessionPath];
    NSData *myData = [NSData dataWithContentsOfFile:path];
    [mailComposer addAttachmentData:myData mimeType:@"Text/XML" fileName:sessionPath];

    NSString *emailBody = [NSString stringWithFormat:@"Heart rate log for %@", sessionPath];
    [mailComposer setMessageBody:emailBody isHTML:NO];
    [self presentViewController:mailComposer animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    if (error) {
        NSLog(@"ERROR: %@", error.localizedDescription);
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
