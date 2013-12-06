//
//  MyScene.m
//  SpriteSimpleGame
//
//  Created by neo on 13-12-7.
//  Copyright (c) 2013年 neo. All rights reserved.
//

#import "MyScene.h"
@interface MyScene ()
@property (nonatomic, strong) SKSpriteNode *player;
@property (nonatomic) NSTimeInterval lastSpawnTime;
@property (nonatomic) NSTimeInterval lastUpdateTime;
@end
@implementation MyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        self.backgroundColor = [SKColor grayColor];
        
        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"player"];
        self.player.position = CGPointMake(self.player.size.width/2, self.frame.size.height/2);
        
        [self addChild:self.player];
    }
    return self;
}
- (void)addMonster
{
    // create
    SKSpriteNode *monster = [SKSpriteNode spriteNodeWithImageNamed:@"monster"];
    
    // position
    int minY = monster.size.height / 2;
    int maxY = self.frame.size.height - monster.size.height / 2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    monster.position = CGPointMake(self.frame.size.width + monster.size.width/2, actualY);
    [self addChild:monster];
    
    //set speed
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    //create action
    SKAction *actionMove = [SKAction moveTo:CGPointMake(-monster.size.width/2, actualY) duration:actualDuration];
    SKAction *actionMoveDone = [SKAction removeFromParent];
    [monster runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast
{
    self.lastSpawnTime += timeSinceLast;
    if (self.lastSpawnTime > 1) {
        self.lastSpawnTime -= 1;
        [self addMonster];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
//    for (UITouch *touch in touches) {
//        CGPoint location = [touch locationInNode:self];
//        
//        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
//        
//        sprite.position = location;
//        
//        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
//        
//        [sprite runAction:[SKAction repeatActionForever:action]];
//        
//        [self addChild:sprite];
//    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTime;
    self.lastUpdateTime = currentTime;
    if (timeSinceLast > 1) {
        timeSinceLast = 1.0f / 60.0f;
        self.lastUpdateTime = currentTime;
    }
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}

@end
