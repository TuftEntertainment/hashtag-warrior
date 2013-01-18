//
//  GameLayer.m
//  hashtag-warrior
//
//  Created by Nick James on 18/01/2013.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "GameLayer.h"


@implementation GameLayer

+ (id)scene
{
    
    CCScene *scene = [CCScene node];
    GameLayer *layer = [GameLayer node];
    [scene addChild:layer];
    return scene;
}

- (id)init
{
    
    if ((self=[super init]))
    {
        // create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Game Layer" fontName:@"Marker Felt" fontSize:64];
        
        // ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        
		// position the label on the center of the screen
		label.position =  ccp( size.width /2 , size.height/2 );
		
		// add the label as a child to this Layer
		[self addChild: label];
    }
    return self;
}

- (void) dealloc
{
	// cocos2d will automatically release all the children.
	
	// Call "super dealloc".
	[super dealloc];
}

@end
