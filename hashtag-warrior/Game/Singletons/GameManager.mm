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

#import "GameManager.h"
#import "AboutScene.h"
#import "GameOverScene.h"
#import "ChooseHashtagScene.h"
#import "GameScene.h"
#import "IntroScene.h"
#import "MainMenuScene.h"

@implementation GameManager

static GameManager* sharedInstance = nil;

@synthesize _currentScene;

+(GameManager*)sharedGameManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[GameManager alloc] init];
    });
    return sharedInstance;
}

-(id)init
{
    self = [super init];
    if (self != nil) {
        _currentScene = kHWNoScene;
    }
    return self;
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

-(void)runSceneWithID:(SceneTypes)sceneID
{
    SceneTypes oldScene = _currentScene;
    _currentScene = sceneID;
    
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
        _currentScene = oldScene;
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