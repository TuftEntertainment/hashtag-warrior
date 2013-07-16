//
//  GameManager.h
//  hashtag-warrior
//
//  The role of the GameManager is to retain knowledge of scenes,
//  and how to switch between them. This keeps Scene coupling to
//  a minimum, and makes it easier to add in scenes later.
//
//  TODO it's also common to initialise audio engines and preload
//  audio effects here.
//
//  Created by Daniel Wood on 05/05/2013.
//  Copyright (c) 2013 Ossum Games. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonProtocols.h"

@interface GameManager : NSObject {
    SceneTypes currentScene;
}

@property (assign) SceneTypes currentScene;

+(GameManager*)sharedGameManager;
-(void)runSceneWithID:(SceneTypes)sceneID;

@end
