//
//  FFShip.m
//  ForestFly
//
//  Created by Jon Como on 1/1/15.
//  Copyright (c) 2015 Jon Como. All rights reserved.
//

#import "FFShip.h"

@implementation FFShip

-(instancetype)init {
    if (self = [super init]) {
        //init
        _speed = CGVectorMake(0, 0.1);
        _node = [SCNNode nodeWithGeometry:[SCNPyramid pyramidWithWidth:.5 height:.5 length:.5]];
        
        // Bobbing animation
        SCNAction *bob = [SCNAction sequence:@[[SCNAction moveByX:0 y:-.2 z:0 duration:1],
                                               [SCNAction moveByX:0 y:.2 z:0 duration:1]]];
        [_node runAction:[SCNAction repeatActionForever:bob]];
    }
    
    return self;
}

- (void)update {
    // Increase speed
    self.speed = CGVectorMake(self.speed.dx * 0.98, self.speed.dy + 0.00001);
    self.node.position = SCNVector3Make(self.node.position.x + self.speed.dx, self.node.position.y, self.node.position.z);
}

@end
