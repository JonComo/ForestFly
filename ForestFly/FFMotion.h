//
//  FFMotion.h
//  ForestFly
//
//  Created by Jon Como on 1/1/15.
//  Copyright (c) 2015 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFMotion : NSObject

@property (nonatomic, assign) float offset;

-(void)startGeneratingMotionUpdates;
-(void)stopGeneratingMotionUpdates;

@end
