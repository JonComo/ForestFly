//
//  GameViewController.m
//  ForestFly
//
//  Created by Jon Como on 1/1/15.
//  Copyright (c) 2015 Jon Como. All rights reserved.
//

#import "GameViewController.h"

#import "FFMotion.h"
#import "FFShip.h"

@interface GameViewController () <SCNSceneRendererDelegate> {
    
    // Scene
    SCNScene *scene;
    SCNView *sceneView;
    
    // Controls
    FFMotion *motion;
    
    // Game variables
    FFShip *ship;
    NSMutableSet *trees;
    NSInteger numTrees;
    NSInteger forestWidth;
    
    SCNNode *cameraNode;
    
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
    
    [motion startGeneratingMotionUpdatesHandler:^(float x) {
        
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
            x = -x;
        }
        
        ship.speed = CGVectorMake(ship.speed.dx + x / 100.f, ship.speed.dy);
    }];
}

- (void)setupScene {
    // create a new scene
    scene = [SCNScene scene];
    sceneView = (SCNView *)self.view;
    
    sceneView.delegate = self;
    
    // create and add a light to the scene
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeAmbient;
    lightNode.position = SCNVector3Make(0, 10, 10);
    [scene.rootNode addChildNode:lightNode];
    
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    
    // set the scene to the view
    scnView.scene = scene;
    
    // show statistics such as fps and timing information
    scnView.showsStatistics = YES;
    
    // configure the view
    scnView.backgroundColor = [UIColor blueColor];
    
    // Setup ship
    ship = [FFShip new];
    [scene.rootNode addChildNode:ship.node];
    
    // create and add a camera to the ship
    cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    [ship.node addChildNode:cameraNode];
    
    // place the camera
    cameraNode.position = SCNVector3Make(0, 1, 4);
}

- (void)setupGame {
    // Configure Game variables
    numTrees = 50;
    forestWidth = 40;
    
    while (trees.count < numTrees) {
        SCNVector3 position = SCNVector3Make([self randomSceneX], 0, -60 + (float)(arc4random()%50));
        [self addTreeToPosition:position];
    }
}

- (void)addTreeToPosition:(SCNVector3)position {
    if (!trees) {
        trees = [NSMutableSet set];
    }
    
    SCNPyramid *pyramid = [SCNPyramid pyramidWithWidth:1 height:1 length:1];
    SCNNode *node = [SCNNode nodeWithGeometry:pyramid];
    node.position = position;
    [scene.rootNode addChildNode:node];
    
    [trees addObject:node];
}

- (CGFloat)randomSceneX {
    return (float)(arc4random()%forestWidth) - forestWidth/2;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)updateTrees {
    NSMutableSet *treesToRemove = [NSMutableSet set];
    for (SCNNode *tree in trees) {
        tree.position = SCNVector3Make(tree.position.x, tree.position.y, tree.position.z + ship.speed.dy);
        if (tree.position.z > 10) {
            [tree removeFromParentNode];
            [treesToRemove addObject:tree];
        }
    }
    
    [trees minusSet:treesToRemove];
}

#pragma mark controls

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    lastTouchPosition = [[touches anyObject] locationInView:sceneView];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint touchPosition = [[touches anyObject] locationInView:sceneView];
    CGFloat difference = touchPosition.x - lastTouchPosition.x;
    
    ship.speed = CGVectorMake(ship.speed.dx + difference / 200.f, ship.speed.dy);
    
    lastTouchPosition = touchPosition;
}

#pragma mark SCNSceneRendererDelegate

-(void)renderer:(id<SCNSceneRenderer>)aRenderer willRenderScene:(SCNScene *)scene atTime:(NSTimeInterval)time {
    [ship update];
    [self updateTrees];
    
    while (trees.count < numTrees) {
        [self addTreeToPosition:SCNVector3Make([self randomSceneX], 0, -30)];
    }
}

@end
