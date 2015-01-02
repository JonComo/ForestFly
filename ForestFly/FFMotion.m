//
//  FFMotion.m
//  ForestFly
//
//  Created by Jon Como on 1/1/15.
//  Copyright (c) 2015 Jon Como. All rights reserved.
//

#import "FFMotion.h"

@import CoreMotion;

@interface FFMotion () {
    CMMotionManager *manager;
}

@end

@implementation FFMotion

-(instancetype)init {
    if (self = [super init]) {
        //init
        
    }
    
    return self;
}

-(void)startGeneratingMotionUpdatesHandler:(MotionUpdate)handler {
    if (!manager) {
        manager = [CMMotionManager new];
    }
    
    if (!manager.isAccelerometerActive) {
        [manager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            if (handler) {
                handler(accelerometerData.acceleration.y);
            }
        }];
    }
}

-(void)stopGeneratingMotionUpdates {
    if (manager.isAccelerometerActive) {
        [manager stopAccelerometerUpdates];
    }
}

@end
