//
//  FFMotion.m
//  ForestFly
//
//  Created by Jon Como on 1/1/15.
//  Copyright (c) 2015 Jon Como. All rights reserved.
//

#import "FFMotion.h"

@import CoreMotion;
@import UIKit;

@interface FFMotion () {
    CMMotionManager *manager;
}

@end

@implementation FFMotion

-(void)startGeneratingMotionUpdates {
    if (!manager) {
        manager = [CMMotionManager new];
    }
    
    __weak FFMotion *weakSelf = self;
    if (!manager.isAccelerometerActive) {
        [manager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
            
            weakSelf.offset = accelerometerData.acceleration.y;
            
            if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft) {
                weakSelf.offset = -weakSelf.offset;
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
