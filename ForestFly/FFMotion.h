//
//  FFMotion.h
//  ForestFly
//
//  Created by Jon Como on 1/1/15.
//  Copyright (c) 2015 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MotionUpdate)(float x);

@interface FFMotion : NSObject

-(void)startGeneratingMotionUpdatesHandler:(MotionUpdate)handler;
-(void)stopGeneratingMotionUpdates;

@end
