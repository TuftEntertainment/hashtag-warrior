//
//  IntroLayer.m
//  hashtag-warrior
//
//  Created by Nick James on 13/01/2013.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "IntroLayer.h"
#import "GameLayer.h"


#pragma mark - IntroLayer

// GameLayer implementation
@implementation IntroLayer

// Helper class method that creates a Scene with the GameLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroLayer *layer = [IntroLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void) onEnter
{
	[super onEnter];

	// ask director for the window size
	CGSize size = [[CCDirector sharedDirector] winSize];
	
    // The application is landscape only, set this scenes background image accoridngly.
    CCSprite *background;
    
	if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone )
    {
		background = [CCSprite spriteWithFile:@"Default.png"];
		background.rotation = 90;
	}
    else
    {
		background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
	}

	background.position = ccp(size.width/2, size.height/2);

	// add the label as a child to this Layer
	[self addChild: background];
	
	// In one second transition to the new scene
	[self scheduleOnce:@selector(makeTransition:) delay:1];
}

-(void) makeTransition:(ccTime)dt
{
    // Fade from the launch image into the application.
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0
                                                                                 scene:[GameLayer scene]
                                                                             withColor:ccWHITE]];
}

- (void) dealloc
{
	// cocos2d will automatically release all the children.
	
	// Call "super dealloc".
	[super dealloc];
}
@end
