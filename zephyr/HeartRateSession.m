//
//  HeartRateSession.m
//  zephyr
//
//  Created by mogura on 12/29/14.
//  Copyright (c) 2014 studystream. All rights reserved.
//

#import "HeartRateSession.h"

@interface HeartRateSession ()
@property (nonatomic, strong) NSFileHandle *sessionFile;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation HeartRateSession

+(NSString *)sessionsFolderPath {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString *sessionsDir = [documentsDir stringByAppendingPathComponent:@"sessions"];
    
    if (![fm fileExistsAtPath:sessionsDir]) {
        NSError *error;
        [fm createDirectoryAtPath:sessionsDir withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"ERROR: %@", error.localizedDescription);
            return nil;
        }
    }
    return sessionsDir;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *filename = [NSString stringWithFormat:@"%@.txt", [self.dateFormatter stringFromDate:[NSDate new]]];
        
        NSString *sessionsFolderPath = [HeartRateSession sessionsFolderPath];
        NSString *sessionPath = [sessionsFolderPath stringByAppendingPathComponent:filename];
        [[NSFileManager defaultManager] createFileAtPath:sessionPath contents:nil attributes:nil];
        
        self.sessionFile = [NSFileHandle fileHandleForUpdatingAtPath:sessionPath];
        [self.sessionFile seekToEndOfFile];
    }
    return self;
}

-(void)logHeartRate:(int)heartRate {
    NSString *time = [self.dateFormatter stringFromDate:[NSDate date]];
    NSString *line = [NSString stringWithFormat:@"%@=%d\n", time, heartRate];
    [self.sessionFile writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
}

-(void)endSession {
    [self.sessionFile closeFile];
}

@end
