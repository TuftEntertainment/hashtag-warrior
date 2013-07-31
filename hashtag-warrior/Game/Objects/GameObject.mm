/*
 * #Warrior - http://tuftentertainment.github.io/hashtag-warrior/
 *
 * The MIT License (MIT)
 *
 * Copyright (c) 2013 Tuft Entertainment
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

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
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                         NSUserDomainMask, YES)[0];
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
    plistDictionary[animationName];
    if (animationSettings == nil) {
        CCLOG(@"Could not locate AnimationWithName:%@",animationName);
        return nil;
    }
    
    // 5: Get the delay value for the animation
    float animationDelay =
    [animationSettings[@"delay"] floatValue];
    
    // 6: Add the frames to the animation
    NSString *animationFramePrefix =
    animationSettings[@"filenamePrefix"];
    NSString *animationFrames =
    animationSettings[@"animationFrames"];
    NSMutableArray *spriteFrames = [NSMutableArray arrayWithArray:[animationFrames componentsSeparatedByString:@","]];
    
    for (NSUInteger i = 0; i < [spriteFrames count]; ++i) {
        NSString *frameName =
        [NSString stringWithFormat:@"%@%@.png", animationFramePrefix, spriteFrames[i]];
        
        spriteFrames[i] = [[CCSpriteFrameCache sharedSpriteFrameCache]
                                                         spriteFrameByName:frameName];
    }
    
    animationToReturn = [CCAnimation animationWithSpriteFrames:spriteFrames delay:animationDelay];
    
    return animationToReturn;
}

@end