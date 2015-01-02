//
//  FFShip.h
//  ForestFly
//
//  Created by Jon Como on 1/1/15.
//  Copyright (c) 2015 Jon Como. All rights reserved.
//

#import "FFObject.h"

@interface FFShip : FFObject

@property (nonatomic, strong) SCNNode *node;
@property (nonatomic, assign) CGVector speed;

@end
