//
//  GameObject.m
//  hashtag-warrior
//
//  Created by Daniel Wood on 28/04/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import "GameObject.h"

@implementation GameObject

@synthesize reactsToScreenBoundaries;
@synthesize screenSize;
@synthesize isActive;
@synthesize gameObjectType;
@synthesize state;
@synthesize physicsBody;

-(id) init {
    if((self = [super init])){
        screenSize = [CCDirector sharedDirector].winSize;
        isActive = TRUE;
        gameObjectType = kNullType;
    }
    
    return self;
}

-(void)changeState:(GameObjectState)newState {
    // Child classes should override this
}

-(void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray*)listOfGameObjects {
    // Child classes should override this
}

-(CGRect)adjustedBoundingBox {
    // Child classes may choose to override this if they want a more accurate bounding box
    return [self boundingBox];
}

-(CCAnimation*)loadPlistForAnimationWithName:(NSString*)animationName andClassName:(NSString*)className {
    
    CCAnimation *animationToReturn = nil;
    NSString *fullFileName =
    [NSString stringWithFormat:@"%@.plist", className];
    NSString *plistPath;
    
    // 1: Get the Path to the plist file
    NSString *rootPath =
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                         NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle]
                     pathForResource:className ofType:@"plist"];
    }
    
    // 2: Read in the plist file
    NSDictionary *plistDictionary =
    [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    // 3: If the plistDictionary was null, the file was not found.
    if (plistDictionary == nil) {
        CCLOG(@"Error reading plist: %@.plist", className);
        return nil; // No Plist Dictionary or file found
    }
    
    // 4: Get just the mini-dictionary for this animation
    NSDictionary *animationSettings =
    [plistDictionary objectForKey:animationName];
    if (animationSettings == nil) {
        CCLOG(@"Could not locate AnimationWithName:%@",animationName);
        return nil;
    }
    
    // 5: Get the delay value for the animation
    float animationDelay =
    [[animationSettings objectForKey:@"delay"] floatValue];
    
    // 6: Add the frames to the animation
    NSString *animationFramePrefix =
    [animationSettings objectForKey:@"filenamePrefix"];
    NSString *animationFrames =
    [animationSettings objectForKey:@"animationFrames"];
    NSMutableArray *spriteFrames = [NSMutableArray arrayWithArray:[animationFrames componentsSeparatedByString:@","]];
    
    for (NSUInteger i = 0; i < [spriteFrames count]; ++i) {
        NSString *frameName =
        [NSString stringWithFormat:@"%@%@.png", animationFramePrefix, [spriteFrames objectAtIndex:i]];
        
        [spriteFrames replaceObjectAtIndex:i
                                withObject:[[CCSpriteFrameCache sharedSpriteFrameCache]
                                                         spriteFrameByName:frameName]];
    }
    
    animationToReturn = [CCAnimation animationWithSpriteFrames:spriteFrames delay:animationDelay];
    
    return animationToReturn;
}

@end