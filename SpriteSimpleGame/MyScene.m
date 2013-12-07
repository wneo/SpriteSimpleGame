//
//  MyScene.m
//  SpriteSimpleGame
//
//  Created by neo on 13-12-7.
//  Copyright (c) 2013年 neo. All rights reserved.
//


//向量运算
static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}
static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}
static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}
static inline float rwLength(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}
// 让向量的长度（模）等于1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}


static const uint32_t projectileCategory    = 0x01 << 0;
static const uint32_t monsterCategory       = 0x01 << 1;

#import "MyScene.h"
#import "GameOverScene.h"
@interface MyScene () <SKPhysicsContactDelegate>
@property (nonatomic, strong) SKSpriteNode *player;
@property (nonatomic) NSTimeInterval lastSpawnTime;
@property (nonatomic) NSTimeInterval lastUpdateTime;
@end
@implementation MyScene

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        self.backgroundColor = [SKColor grayColor];
        
        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"player"];
        self.player.position = CGPointMake(self.player.size.width/2, self.frame.size.height/2);
        
        [self addChild:self.player];
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
    }
    return self;
}
- (void)addMonster
{
    // create
    SKSpriteNode *monster = [SKSpriteNode spriteNodeWithImageNamed:@"monster"];
    
    monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monster.size];
    monster.physicsBody.dynamic = YES;//移动是否会受物理引擎影响
    monster.physicsBody.categoryBitMask = monsterCategory;//当前sprite的掩码位
    monster.physicsBody.contactTestBitMask = projectileCategory;//碰撞对象
    monster.physicsBody.collisionBitMask = 0;//物理引擎是否需要处理碰撞事件
 
    
    
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
    //SKAction *actionMoveDone = [SKAction removeFromParent];
	SKAction *lostAction = [SKAction runBlock:^{
		SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
		SKScene *gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:NO];
		[self.view presentScene:gameOverScene transition:reveal];
	}];
    [monster runAction:[SKAction sequence:@[actionMove, lostAction]]];
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
    // 1. 读取位置
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    // 2. 初始化子弹位置
    SKSpriteNode *projectile = [SKSpriteNode spriteNodeWithImageNamed:@"projectile"];
    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
    projectile.physicsBody.dynamic = YES;
    projectile.physicsBody.categoryBitMask = projectileCategory;
    projectile.physicsBody.contactTestBitMask = monsterCategory;
    projectile.physicsBody.collisionBitMask = 0;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;//快速移动的对象预检测机制
    
    projectile.position = self.player.position;

    
    // 3. 计算偏移量
    CGPoint offset = rwSub(location, projectile.position);
    
    // 4. 向后射不处理
    if (offset.x < 0) {
        return;
    }
    
    // 5. 添加子弹
    [self addChild:projectile];
    
    // 6. 读取子弹射出方向
    CGPoint direction = rwNormalize(offset);
    
    // 7. 设定子弹的目标位置
    CGPoint shootAmount = rwMult(direction, 1000.0f);
    
    // 8. 子弹真实目标位置
    CGPoint realDest = rwAdd(projectile.position, shootAmount);
    
    // 9.创建action
    float velocity = 480.0f / 1.0f;
    float realMoveDuration = self.size.width / velocity;
    SKAction *actionMove = [SKAction moveTo:realDest duration:realMoveDuration];
    SKAction *actionMoveDone = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[actionMove, actionMoveDone]]];
    
}

- (void)projectile:(SKSpriteNode *)projectile didCollideWithMonster:(SKSpriteNode *)monster
{
    NSLog(@"Tips: hit");
    [projectile removeFromParent];
    [monster removeFromParent];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
	[self runAction:[SKAction playSoundFileNamed:@"pew-pew-lei.caf" waitForCompletion:NO]];
    // 1. 排序区分对象
    SKPhysicsBody *firstBody, *secondBody;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }else{
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    // 2.检测碰撞
    if ((firstBody.categoryBitMask & projectileCategory) != 0
        && (secondBody.categoryBitMask & monsterCategory) != 0) {
        [self projectile:(SKSpriteNode *)firstBody.node didCollideWithMonster:(SKSpriteNode *)secondBody.node];
    }
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
