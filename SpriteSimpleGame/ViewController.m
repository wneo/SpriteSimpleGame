//
//  ViewController.m
//  SpriteSimpleGame
//
//  Created by neo on 13-12-7.
//  Copyright (c) 2013年 neo. All rights reserved.
//

#import "ViewController.h"
#import "MyScene.h"

@import AVFoundation;
@interface ViewController ()
@property (nonatomic) AVAudioPlayer *backGroundMusicPlayer;
@end
@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)test:(id)who
{
    NSInteger i = 0;
    for (;i<10000; i++) {
        NSLog(@"%@:%d", who, i);
    }
}
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
	// back ground music
	NSURL * backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"background-music-aac"
														 withExtension:@"caf"];
	NSError *error = nil;
	self.backGroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
	if (error != nil) {
		NSLog(@"Warn: loading back ground music filed:%@", error);
	}else{
		self.backGroundMusicPlayer.numberOfLoops = -1;
		[self.backGroundMusicPlayer prepareToPlay];
		[self.backGroundMusicPlayer play];
	}
	
	
	
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    skView.showsDrawCount = YES;
    
    // Create and configure the scene.
    SKScene * scene = [MyScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
	
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
