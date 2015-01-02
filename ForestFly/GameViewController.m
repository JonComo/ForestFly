//
//  GameViewController.m
//  ForestFly
//
//  Created by Jon Como on 1/1/15.
//  Copyright (c) 2015 Jon Como. All rights reserved.
//

#import "GameViewController.h"

#import "FFMotion.h"

@interface GameViewController () <SCNSceneRendererDelegate> {
    // Scene
    SCNScene *scene;
    SCNView *sceneView;
    
    // Controls
    FFMotion *motion;
    
    // Game variables
    CGVector speed;
    NSMutableSet *trees;
    NSInteger numTrees;
    NSInteger forestWidth;
    BOOL gameOver;
    
    SCNNode *cameraNode;
    CGFloat camRotation;
    SCNNode *planeNode;
    SCNNode *lightNode;
    
    // Touch controls (debugging)
    CGPoint lastTouchPosition;
}

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupScene];
    [self setupGame];
    [self setupControls];
}

- (void)setupControls {
    motion = [FFMotion new];
    [motion startGeneratingMotionUpdates];
}

- (void)setupScene {
    // create a new scene
    scene = [SCNScene scene];
    sceneView = (SCNView *)self.view;
    
    sceneView.delegate = self;
    
    // create and add a light to the scene
    lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    lightNode.light.shadowColor = [UIColor blackColor];
    
    SCNAction *bob = [SCNAction moveByX:0 y:1 z:0 duration:1];
    [lightNode runAction:[SCNAction repeatActionForever:bob]];
    
    [scene.rootNode addChildNode:lightNode];
    
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    
    // set the scene to the view
    scnView.scene = scene;
    
    // show statistics such as fps and timing information
    scnView.showsStatistics = YES;
    
    // configure the view
    scnView.backgroundColor = [UIColor colorWithRed:0 green:210.f/255.f blue:1.f alpha:1];
    
    // Create camera (ship)
    cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    cameraNode.camera.xFov = 100;
    cameraNode.camera.yFov = 100;
    cameraNode.camera.zNear = 0.01;
    [scene.rootNode addChildNode:cameraNode];
    
    cameraNode.position = SCNVector3Make(0, 2, 1);
    
    // Setup ground plane
    SCNPlane *plane = [SCNPlane planeWithWidth:1000 height:1000];
    SCNMaterial *green = [SCNMaterial material];
    green.diffuse.contents = [UIColor colorWithRed:30.f/255.f green:166.f/255.f blue:89.f/255.f alpha:1.f];
    plane.materials = @[green];
    planeNode = [SCNNode nodeWithGeometry:plane];
    planeNode.pivot = SCNMatrix4MakeRotation(M_PI_2, 1, 0, 0);
    
    [scene.rootNode addChildNode:planeNode];
}

- (void)setupGame {
    // Configure Game variables
    numTrees = 100;
    forestWidth = 200;
    gameOver = NO;
    speed = CGVectorMake(0.0, 0.1);
    
    while (trees.count < numTrees) {
        SCNVector3 position = SCNVector3Make(round([self randomSceneX] / 2.f) * 2, 0, -60 + round((float)(arc4random()%50) / 2.f) * 2);
        [self addTreeToPosition:position];
    }
}

#pragma mark SCNSceneRendererDelegate

-(void)renderer:(id<SCNSceneRenderer>)aRenderer willRenderScene:(SCNScene *)scene atTime:(NSTimeInterval)time {
    if (gameOver) {
        return;
    }
    
    speed = CGVectorMake((speed.dx - motion.offset) * 0.7f, speed.dy + 0.0001);
    
    cameraNode.position = SCNVector3Make(cameraNode.position.x + speed.dx, cameraNode.position.y, cameraNode.position.z);
    camRotation -= (camRotation - speed.dx) / 20.0f;
    cameraNode.pivot = SCNMatrix4MakeRotation(camRotation, 0, 0, 0.2f);
    
    planeNode.position = SCNVector3Make(cameraNode.position.x, 0, 0);
    lightNode.position = SCNVector3Make(cameraNode.position.x, 10, 10);
    
    // Tree updates
    [self updateTrees];
    
    if ([self hitTree]) {
        gameOver = YES;
    }
    
    while (trees.count < numTrees) {
        [self addTreeToPosition:SCNVector3Make([self randomSceneX], 0, -30)];
    }
}

- (void)addTreeToPosition:(SCNVector3)position {
    if (!trees) {
        trees = [NSMutableSet set];
    }
    
    SCNPyramid *pyramid = [SCNPyramid pyramidWithWidth:2 height:3 length:2];
    SCNNode *node = [SCNNode nodeWithGeometry:pyramid];
    node.position = position;
    
    SCNMaterial *color = [SCNMaterial material];
    color.diffuse.contents = [UIColor colorWithHue:(float)(arc4random()%100)/100.f saturation:1 brightness:1 alpha:1];
    pyramid.materials = @[color];
    
    [scene.rootNode addChildNode:node];
    
    [trees addObject:node];
}

- (CGFloat)randomSceneX {
    return cameraNode.position.x + (float)(arc4random()%forestWidth) - forestWidth/2;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)updateTrees {
    NSMutableSet *treesToRemove = [NSMutableSet set];
    for (SCNNode *tree in trees) {
        tree.position = SCNVector3Make(tree.position.x, tree.position.y, tree.position.z + speed.dy);
        if (tree.position.z > 10) {
            [tree removeFromParentNode];
            [treesToRemove addObject:tree];
        }
    }
    
    [trees minusSet:treesToRemove];
}

- (SCNNode *)hitTree {
    CGFloat dist = 0.3;
    for (SCNNode *tree in trees) {
        CGFloat zDiff = cameraNode.position.z - tree.position.z;
        if (ABS(cameraNode.position.x - tree.position.x) < dist && zDiff < .4 + speed.dy && zDiff > 0) {
            return tree;
        }
    }
    
    return nil;
}

#pragma mark controls

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (gameOver) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    lastTouchPosition = [[touches anyObject] locationInView:sceneView];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchPosition = [[touches anyObject] locationInView:sceneView];
    CGFloat difference = touchPosition.x - lastTouchPosition.x;
    
    speed = CGVectorMake(speed.dx + difference / 20.f, speed.dy);
    
    lastTouchPosition = touchPosition;
}

@end
