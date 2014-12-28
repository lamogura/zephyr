//
//  HeartRateSession.h
//  zephyr
//
//  Created by mogura on 12/29/14.
//  Copyright (c) 2014 studystream. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HeartRateSession : NSObject

+(NSString *)sessionsFolderPath;

-(void)logHeartRate:(int)heartRate;

-(void)endSession;

@end
