//
//  GameOverScene.m
//  SpriteSimpleGame
//
//  Created by neo on 13-12-7.
//  Copyright (c) 2013年 neo. All rights reserved.
//

#import "GameOverScene.h"
#import "MyScene.h"

@implementation GameOverScene
- (id)initWithSize:(CGSize)size won:(BOOL)won
{
	self = [super initWithSize:size];
	if (self) {
		self.backgroundColor = [SKColor whiteColor];
		
		NSString *message = @"You won!";
		if (! won) {
			message = @"You lost!";
		}
		SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        label.text = message;
		label.fontColor = [SKColor redColor];
		label.fontSize = 40.0f;
		label.position = CGPointMake(self.size.width/2, self.size.height/2);
		[self addChild:label];
		
		
		[self runAction:[SKAction sequence:@[
			[SKAction waitForDuration:3.0f],
			[SKAction runBlock:^{
				SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
				SKScene *myScene = [[MyScene alloc] initWithSize:self.size];
				[self.view presentScene:myScene transition:reveal];
				
				}]]
			]
		 ];
	}
	return self;
}
@end
