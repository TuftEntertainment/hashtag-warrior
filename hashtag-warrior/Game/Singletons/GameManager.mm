//
//  GameManager.m
//  hashtag-warrior
//
//  Created by Daniel Wood on 05/05/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import "GameManager.h"
#import "AboutScene.h"
#import "GameOverScene.h"
#import "ChooseHashtagScene.h"
#import "GameScene.h"
#import "IntroScene.h"
#import "MainMenuScene.h"

@implementation GameManager

static GameManager* _sharedGameManager = nil;

@synthesize currentScene;

+(GameManager*)sharedGameManager
{
    @synchronized([GameManager class])
    {
        if(!_sharedGameManager) {
            [[self alloc] init];
        }
        return _sharedGameManager;
    }
    return nil;
}

+(id)alloc
{
    @synchronized ([GameManager class])
    {
        NSAssert(_sharedGameManager == nil,
                 @"Attempted to allocate a second instance of the Game Manager singleton");
        _sharedGameManager = [super alloc];
        return _sharedGameManager;
    }
    return nil;
}

- (NSString*)formatSceneTypeToString:(SceneTypes)sceneID
{
    NSString *result = nil;
    switch(sceneID) {
        case kHWNoScene:
            result = @"kHWNoScene";
            break;
        case kHWMainMenuScene:
            result = @"kHWMainMenuScene";
            break;
        case kHWAboutScene:
            result = @"kHWAboutScene";
            break;
        case kHWIntroScene:
            result = @"kHWIntroScene";
            break;
        case kHWGameOverScene:
            result = @"kHWGameOverScene";
            break;
        case kHWChooseHashtagScene:
            result = @"kHWChooseHashtagScene";
            break;
        case kHWGameScene:
            result = @"kHWGameScene";
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected SceneType."];
    }
    return result;
}

-(id)init
{
    self = [super init];
    if (self != nil) {
        currentScene = kHWNoScene;
    }
    return self;
}

-(void)runSceneWithID:(SceneTypes)sceneID
{
    SceneTypes oldScene = currentScene;
    currentScene = sceneID;
    
    id sceneToRun = nil;
    switch (sceneID) {
        case kHWMainMenuScene:
            sceneToRun = [MainMenuScene node];
            break;
        case kHWAboutScene:
            sceneToRun = [AboutScene node];
            break;
        case kHWIntroScene:
            sceneToRun = [IntroScene node];
            break;
        case kHWGameOverScene:
            sceneToRun = [GameOverScene node];
            break;
        case kHWChooseHashtagScene:
            sceneToRun = [ChooseHashtagScene node];
            break;
        case kHWGameScene:
            sceneToRun = [GameScene node];
            break;
            
        default:
            CCLOG(@"Unknown ID, cannot switch scenes");
            return;
            break;
    }
    
    if (sceneToRun == nil) {
        // Unknown scene, go back to previous
        currentScene = oldScene;
        return;
    }
    
    // Ensure we only "runWithScene" once - all subsequent calls should be replaceScene
    if ([[CCDirector sharedDirector] runningScene] == nil) {
        [[CCDirector sharedDirector] runWithScene:sceneToRun];
        
    } else {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:sceneToRun]];
    }
}

@end