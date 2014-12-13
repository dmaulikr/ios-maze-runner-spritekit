//
//  GameViewController.h
//  SpeedMaze
//

//  Copyright (c) 2014 beefSama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <Foundation/Foundation.h>
#import "MazeGenerator.h"
#import "GameScene.h"
#import "MazeScene.h"
#import "GamepadScene.h"


@interface GameViewController : UIViewController <GamepadSceneDelegate>

@property (weak, nonatomic) MazeScene *mazeScene;

@end
