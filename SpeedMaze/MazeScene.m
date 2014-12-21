//
//  MazeScene.m
//  SpeedMaze
//
//  Created by Enlan Zhou on 12/7/14.
//  Copyright (c) 2014 beefSama. All rights reserved.
//

#import "MazeScene.h"

@interface MazeScene ()
/**
 *  draw the grid of maze
 */
-(void)drawAllWallsAsOneNode;

/**
 *  draw different types of cell walls. e.g. tube shape
 */
-(void)drawAllWallsWithCellWallTypes;

/**
 *  simple method to paint/draw the solution path
 */
-(void)drawSolutionPath;

/**
 *  need to run these method accordinglyl to have the
 *  effect of mazeAvatar. These method need to indentify
 *  avatar type. and will grab the necessary property frome
 *  interface
 */
-(void)mazeAvatarBeforeMove; //before leaving the tile it was stood on
-(void)mazeAvatarIsMoving; //for every tile it passes
-(void)mazeAvatarDidMove; //after it stop, arrives the destination
-(void)mazeAvatarInvokeSkill; // pressed 'S'

@end

@implementation MazeScene

static float squareLength;
static float squareWallThickness;

-(void)didMoveToView:(SKView *)view{
    self.backgroundColor = [SKColor blueColor];
    if (ZenDebug>=2) {
        NSLog(@"MazeScene didMoveToView");
    }
    NSLog(@"didMoveToView: %f, %f, %f, %f",self.frame.origin.x,self.frame.origin.y,self.frame.size.width,self.frame.size.height);
    NSLog(@"square length and thickness: %f, %f", squareLength, squareWallThickness);
    
    [self drawAllWallsAsOneNode];
    //[self drawAllWallsWithCellWallTypes];
    //[self drawSolutionPath];
    
    
    SKSpriteNode *avatar = [[SKSpriteNode alloc] initWithColor:[UIColor blackColor] size:CGSizeMake(squareLength*0.6, squareLength*0.6)];
    self.avatar = avatar;
    
    // mark the original maze cell that avatar is at
    self.avatarMazeCell = [self.theMaze.mazeGraph getCellAtX:0 y:0];
    
    //place avatar at (0,0)
    //self.avatar.position = CGPointMake(squareLength/2,squareLength/2);
    [self calculateAvatarNodePositionWithAvatarCell];
    [self addChild:self.avatar];
    
    //setup avatar type and its basic
    //just default for testing
    //self.mazeAvatar = [[MazeAvatar alloc] initWithAvatarType:mazeAvatarBlackBox];
    // testing giraffe
    //self.mazeAvatar = [[MazeAvatar alloc] initWithAvatarType:mazeAvatarGiraffe];
    // testing snail
    //self.mazeAvatar = [[MazeAvatar alloc] initWithAvatarType:mazeAvatarSnail];
    if (self.mazeAvatar == nil) {
        NSLog(@"MazeScene: avatar is nil");
        self.mazeAvatar = [[MazeAvatar alloc] initWithAvatarType:mazeAvatarBlackBox];
    }
    
    // init the mazeAvatar according to their types
    //pushing the initial cell to array
    if (self.mazeAvatar.avatarType == mazeAvatarBlackBox) {
        [self.mazeAvatar mazeAvatarBlackBoxStepAt:self.avatarMazeCell];
        // draw mist after initial placement of avatar
        [self drawMistAsOneNodeWithItsSightWithAvatarMazeCell:self.avatarMazeCell];
    }
    else if(self.mazeAvatar.avatarType == mazeAvatarGiraffe){
        self.avatar.color = [UIColor brownColor];
        // draw mist after initial placement of avatar
        [self drawMistAsOneNodeWithItsSightWithAvatarMazeCell:self.avatarMazeCell];
    }
    else if (self.mazeAvatar.avatarType == mazeAvatarSnail){
        self.avatar.color = [UIColor yellowColor];
        [self.mazeAvatar mazeAvatarSnailAddAMazeCell:self.avatarMazeCell];
        [self drawMistAsOneNodeWithItsSightWithAvatarMazeCell:self.avatarMazeCell];
    }
    else if (self.mazeAvatar.avatarType == mazeAvatarSunday){
        self.avatar.color = [UIColor redColor];
        //do nothing, this avatar has no mist
    }
    
    
    /*
    SKShapeNode *square2 = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(squareLength, squareLength)];
    //square2.
    square2.position = nil;
    //square2.frame = CGRectMake(100, 100, 200, 200);
    square2.lineWidth = 5;
    square2.fillColor = [UIColor blackColor];
    square2.strokeColor = [UIColor redColor];
    [self addChild:square2];
    */
    
    /*
    float squareLength = self.frame.size.width / self.theMaze.mazeGraph.width;
    for (int row = 0; row < self.theMaze.mazeGraph.height; row++) {
        for (int col = 0; col < self.theMaze.mazeGraph.width; col++) {
            SKShapeNode *square = [SKShapeNode shapeNodeWithRect:CGRectMake(col*squareLength, row*squareLength, squareLength, squareLength)];
            square.path = [[self drawWallWithCell:[self.theMaze.mazeGraph getCellAtX:col y:row] withSquareLength:squareLength] CGPath];
            //square.position = CGPointMake(160, 160);
            square.lineWidth = squareLength / 10.0;
            square.strokeColor = [SKColor blueColor];
            square.fillColor = [SKColor clearColor];
            [self addChild:square];
            NSLog(@"%f, %f, %f, %f",square.frame.origin.x,square.frame.origin.y,square.frame.size.width,square.frame.size.height);
        }
    }
    */
    //self.backgroundColor = [SKColor greenColor];
    
    

    
}

-(void)drawAllWallsAsOneNode{
    SKShapeNode *square = [SKShapeNode node];
    UIBezierPath* wallPath = [[UIBezierPath alloc] init];
    //from origin point, draw bottom line
    [wallPath moveToPoint:CGPointMake(0.0, 0.0)];
    for (int row = 0; row < self.theMaze.mazeGraph.height; row++) {
        for (int col = 0; col < self.theMaze.mazeGraph.width; col++) {
            [wallPath moveToPoint:CGPointMake(squareLength*col, squareLength*row)];
            MazeCell *cell =[self.theMaze.mazeGraph getCellAtX:col y:row];
            
            /**
             *  draw bottom wall, skip the drawing of entrance
             */
            if ((cell.wallOpenBitMask & BottomWallOpen) || (col == 0 && row == 0)){
                [wallPath moveToPoint:CGPointMake(squareLength*col + squareLength ,squareLength*row)];
            }
            else{
                [wallPath addLineToPoint:CGPointMake(squareLength*col + squareLength ,squareLength*row)];
            }
            
            /**
             *  draw right wall, skip the drawing of exit
             */
            if ((cell.wallOpenBitMask & RightWallOpen)) {
                [wallPath moveToPoint:CGPointMake(squareLength*col + squareLength ,squareLength*row + squareLength)];
            }
            else{
                [wallPath addLineToPoint:CGPointMake(squareLength*col + squareLength ,squareLength*row + squareLength)];
            }
            
            /**
             *  draw top wall,skip the drawing of exist
             */
            if ((cell.wallOpenBitMask & TopWallOpen) || (col == self.theMaze.mazeGraph.width -1 && row == self.theMaze.mazeGraph.height-1)) {
                [wallPath moveToPoint:CGPointMake(squareLength*col,squareLength*row + squareLength)];
            }
            else{
                [wallPath addLineToPoint:CGPointMake(squareLength*col,squareLength*row + squareLength)];
            }
            
            /**
             *  draw left wall,skip the drawing of entrance
             */
            if ((cell.wallOpenBitMask & LeftWallOpen)) {
                [wallPath moveToPoint:CGPointMake(squareLength*col,squareLength*row)];
            }
            else{
                [wallPath addLineToPoint:CGPointMake(squareLength*col,squareLength*row)];
            }

            
        }
    }
    square.path = [wallPath CGPath];
    
    //thickness of walls
    square.lineWidth = squareLength / 5.0;
    square.lineCap = kCGLineCapSquare;
    square.strokeColor = [SKColor whiteColor];
    //square.fillColor = [SKColor clearColor];
    self.mazeLayout = square;
    
    NSLog(@"drawAllWallsAsOneNode: %f, %f, %f, %f",square.frame.origin.x,square.frame.origin.y,square.frame.size.width,square.frame.size.height);
    
    [self addChild:self.mazeLayout];
}

-(UIBezierPath *)drawWallWithCell:(MazeCell *)cell withSquareLength:(float)squareLength{
    UIBezierPath* wallPath = [[UIBezierPath alloc] init];
    //from origin point, draw bottom line
    [wallPath moveToPoint:CGPointMake(0.0, 0.0)];
    [wallPath addLineToPoint:CGPointMake(30.0,30.0)];
    [wallPath moveToPoint:CGPointMake(100.0, 100.0)];
    [wallPath addLineToPoint:CGPointMake(130.0,130.0)];

    if (cell.wallOpenBitMask & BottomWallOpen) {
        NSLog(@"bootom wall open at %d,%d",cell.x,cell.y);
        
    }
    /*
    //from origin point, draw bottom line
    [wallPath moveToPoint:CGPointMake(0.0, 0.0)];
    if (cell.wallOpenBitMask & BottomWallOpen) {
        [wallPath addLineToPoint:CGPointMake(0.0,squareLength)];
    }
    
    //from origin point, draw bottom line
    [wallPath moveToPoint:CGPointMake(0.0, 0.0)];
    if (cell.wallOpenBitMask & BottomWallOpen) {
        [wallPath addLineToPoint:CGPointMake(0.0,squareLength)];
    }
    
    //from origin point, draw bottom line
    [wallPath moveToPoint:CGPointMake(0.0, 0.0)];
    if (cell.wallOpenBitMask & BottomWallOpen) {
        [wallPath addLineToPoint:CGPointMake(0.0,squareLength)];
    }
    
     */
    
    

    return wallPath;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        SKShapeNode *square2 = [SKShapeNode shapeNodeWithRect:CGRectMake(0,0,squareLength,squareLength)];
        //square2.
        square2.position = location;
        square2.lineWidth = 5;
        square2.fillColor = [SKColor blackColor];
        square2.strokeColor = [SKColor redColor];
        [self addChild:square2];
        NSLog(@"touchesBegan: %f, %f, %f, %f",square2.frame.origin.x,square2.frame.origin.y,square2.frame.size.width,square2.frame.size.height);
        
        /*
        //test
        SKShapeNode *square = [SKShapeNode node];
        UIBezierPath* wallPath = [[UIBezierPath alloc] init];
        //from origin point, draw bottom line
        [wallPath moveToPoint:CGPointMake(0.0, 0.0)];
        [wallPath addLineToPoint:CGPointMake(10.0,30.0)];
        [wallPath moveToPoint:CGPointMake(squareLength.0, 1squareLength.0)];
        [wallPath addLineToPoint:CGPointMake(100.0,300.0)];
        square.path = [wallPath CGPath];
        square.lineWidth = 2;
        square.strokeColor = [SKColor grayColor];
        [self addChild:square];
         */
    }
}

-(instancetype)initWithMaze:(MazeGenerator *)maze andScreenSize:(CGSize)screenSize{
    self = [super initWithSize:screenSize];
    if(self == nil){
        return nil;
    }
    self.theMaze = maze;
    self.visibleCells = [NSMutableSet set];
    squareLength = self.size.width / self.theMaze.mazeGraph.width;
    squareWallThickness = squareLength / 10.0;

    /*
    self.twoDSKNodes = [[NSMutableArray alloc] initWithCapacity:self.theMaze.mazeGraph.width];
    for (int i = 0; i < self.theMaze.mazeGraph.width; i++) {
        self.twoDSKNodes[i] = [[NSMutableArray alloc] initWithCapacity:self.theMaze.mazeGraph.height];
        for (int j = 0; j < self.theMaze.mazeGraph.height; j++) {
            self.twoDSKNodes[i][j] = [SKShapeNode node];
        }
    }
    */
    return self;
}

-(instancetype)initWithMaze:(MazeGenerator *)maze andScreenSize:(CGSize)screenSize andAvatarType:(mazeAvatarType)avatarType{
    self = [self initWithMaze:maze andScreenSize:screenSize];
    if (self == nil) {
        return self;
    }
    self.mazeAvatar = [[MazeAvatar alloc] initWithAvatarType:avatarType];
    return self;
}


-(void)drawAllWallsWithCellWallTypes{
    for (int row = 0; row < self.theMaze.mazeGraph.height; row++) {
        for (int col = 0; col < self.theMaze.mazeGraph.width; col++) {
            MazeCell *thisCell =[self.theMaze.mazeGraph getCellAtX:col y:row];
            if (thisCell.wallShapeBitMask == wallVerticalTubeShapeType ||thisCell.wallShapeBitMask == wallHorizontalTubeShapeType) {
                //[self drawWallsWithTubeWallShapeTypeWithColumn:col andRow:row];
            }
            if (thisCell.wallShapeBitMask != wallVerticalTubeShapeType && thisCell.wallShapeBitMask != wallHorizontalTubeShapeType) {
                [self drawWallsWithDefaultWallShapeTypeWithColumn:col andRow:row];
            }
        }
    }
}

-(void)drawWallsWithDefaultWallShapeTypeWithColumn:(int)col andRow:(int)row{
    SKShapeNode *square = [SKShapeNode shapeNodeWithRect:CGRectMake(col*squareLength+squareLength*0.1,row*squareLength+squareLength*0.1,squareLength*0.8,squareLength*0.8)];
    //square.lineWidth = 5;
    //square.strokeColor = [SKColor redColor];
    square.fillColor = ZenMyBluenWithAlpha(0.5);
    [self addChild:square];
    if (ZenDebug>=3) {
        NSLog(@"TubeWall: %f, %f, %f, %f",square.frame.origin.x,square.frame.origin.y,square.frame.size.width,square.frame.size.height);
    }
}

-(void)drawWallsWithTubeWallShapeTypeWithColumn:(int)col andRow:(int)row{
    SKShapeNode *square = [SKShapeNode shapeNodeWithRect:CGRectMake(col*squareLength,row*squareLength,squareLength,squareLength)];
    //square.lineWidth = 5;
    //square.strokeColor = [SKColor redColor];
    square.fillColor = ZenMyGreenWithAlpha(0.5);
    [self addChild:square];
    if (ZenDebug>=3) {
        NSLog(@"TubeWall: %f, %f, %f, %f",square.frame.origin.x,square.frame.origin.y,square.frame.size.width,square.frame.size.height);
    }
}

-(void)drawSolutionPath{
    SKShapeNode *solutionPath = [SKShapeNode node];
    UIBezierPath* wallPath = [[UIBezierPath alloc] init];
    //move to the center of (0,0)
    [wallPath moveToPoint:CGPointMake(squareLength / 2, squareLength / 2)];
    for (MazeCell *step in self.theMaze.path) {
        CGRect thisNode = CGRectMake(step.x*squareLength,step.y*squareLength,squareLength,squareLength);
        [wallPath addLineToPoint:CGPointMake(CGRectGetMidX(thisNode), CGRectGetMidY(thisNode))];
        
        if (ZenDebug>=3) {
            NSString *B = (step.wallOpenBitMask & BottomWallOpen) ? @"Y" :@"N";
            NSString *R = (step.wallOpenBitMask & RightWallOpen) ? @"Y" :@"N";
            NSString *T = (step.wallOpenBitMask & TopWallOpen) ? @"Y" :@"N";
            NSString *L = (step.wallOpenBitMask & LeftWallOpen) ? @"Y" :@"N";
            NSLog(@"solutionPath: (%i, %i), OpenWall: B:%@ R:%@ T:%@ L:%@",step.x,step.y,B,R,T,L);
        }
    }
    solutionPath.path = [wallPath CGPath];
    solutionPath.lineWidth = squareLength * 8 / 10;
    solutionPath.strokeColor = [SKColor redColor];
    [self addChild:solutionPath];
}

-(void)update:(NSTimeInterval)currentTime{
    
}

/**
 *  delegate method, to play with maze
 *
 *  @param keyName from the other SKView that has gamepad
 */
-(void)gamepadControlMoveTo:(NSString *)keyName{
    NSLog(@"avatarCell x:%i,y:%i",self.avatarMazeCell.x,self.avatarMazeCell.y);
    
    // detect skill, and filter out those have only passive skill
    if ([keyName isEqualToString:@"S"] && self.mazeAvatar.avatarType != mazeAvatarGiraffe) {
        [self mazeAvatarInvokeSkill];
    }
    else{
        //record the direction passed in
        self.directionWasPressed = keyName;
        
        //MazeAvatar, do something to the mazeAvatar here, when it needs action before moving
        
        
        // move avatar(node and cell) according to key stroke
        [self moveAvatarAccordingToMazeCell:self.avatar mazeCell:self.avatarMazeCell inDirection:keyName];
    }
    // draw mist after moment
    [self drawMistAsOneNodeWithItsSightWithAvatarMazeCell:self.avatarMazeCell];
}

/**
 *  if the wall in that driection is open, and the destination cell is tubeType, keep going
 *
 *  @param avatar   avatar
 *  @param mazeCell the mazeCell that avatar is at
 *  @param keyName  U L D R
 */
-(void)moveAvatarAccordingToMazeCell:(SKSpriteNode *)avatar mazeCell:(MazeCell *)mazeCell inDirection:(NSString *)keyName{
    if (ZenDebug>=3) {
        [mazeCell printCellOpenWallBitMask];
    }
    MazeCell *fromCell = mazeCell;
    
    if ([keyName isEqualToString:@"U"]) {
        while ((mazeCell.wallOpenBitMask & TopWallOpen)) {
            NSLog(@"walling in %@",keyName);
            //avatar.position = CGPointMake(avatar.position.x, avatar.position.y + squareLength);
            mazeCell =  [self.theMaze.mazeGraph getCellAtX:mazeCell.x y:mazeCell.y+1];
            self.avatarMazeCell = mazeCell;
            [self mazeAvatarIsMoving];
            [self calculateAvatarNodePositionWithAvatarCell];
            NSLog(@"move avatarCell end at x:%i,y:%i",self.avatarMazeCell.x,self.avatarMazeCell.y);
            if (mazeCell.wallShapeBitMask != wallVerticalTubeShapeType) {
                break;
            }
        }
    }
    else if ([keyName isEqualToString:@"L"]) {
        while ((mazeCell.wallOpenBitMask & LeftWallOpen) ) {
            NSLog(@"walling in %@",keyName);
            //avatar.position = CGPointMake(avatar.position.x - squareLength, avatar.position.y);
            mazeCell =  [self.theMaze.mazeGraph getCellAtX:mazeCell.x-1 y:mazeCell.y];
            self.avatarMazeCell = mazeCell;
            [self mazeAvatarIsMoving];
            [self calculateAvatarNodePositionWithAvatarCell];
            if (mazeCell.wallShapeBitMask != wallHorizontalTubeShapeType) {
                break;
            }
        }
    }
    else if ([keyName isEqualToString:@"D"]) {
        while ((mazeCell.wallOpenBitMask & BottomWallOpen) ) {
            NSLog(@"walling in %@",keyName);
            //avatar.position = CGPointMake(avatar.position.x, avatar.position.y - squareLength);
            mazeCell =  [self.theMaze.mazeGraph getCellAtX:mazeCell.x y:mazeCell.y-1];
            self.avatarMazeCell = mazeCell;
            [self mazeAvatarIsMoving];
            [self calculateAvatarNodePositionWithAvatarCell];
            if (mazeCell.wallShapeBitMask != wallVerticalTubeShapeType) {
                break;
            }
        }
    }
    else if ([keyName isEqualToString:@"R"]) {
        while ((mazeCell.wallOpenBitMask & RightWallOpen) ) {
            NSLog(@"walling in %@",keyName);
            //avatar.position = CGPointMake(avatar.position.x + squareLength, avatar.position.y);
            mazeCell =  [self.theMaze.mazeGraph getCellAtX:mazeCell.x+1 y:mazeCell.y];
            self.avatarMazeCell = mazeCell;
            [self mazeAvatarIsMoving];
            [self calculateAvatarNodePositionWithAvatarCell];
            if (mazeCell.wallShapeBitMask != wallHorizontalTubeShapeType) {
                break;
            }
        }
    }
    
    if (fromCell == self.avatarMazeCell) {
        //then it's not moving, or not make a mode
    }
    else{
        //did move
        [self mazeAvatarDidMove];
    }
}

/**
 *  Do this everythime after avatar done moving, to re-caculate sight and 
 *  re-draw mist. After node of mist is added to view, all cell.hasMist
 *  should return to YES;(restore the state after finishing adding mist)
 *
 *  @param avatarMazeCell location of avatar
 */
-(void)drawMistAsOneNodeWithItsSightWithAvatarMazeCell:(MazeCell *)avatarMazeCell{
    if (self.mazeAvatar.avatarType == mazeAvatarBlackBox){
        [self straightSightOfAvatar:avatarMazeCell];
    }
    else if(self.mazeAvatar.avatarType == mazeAvatarGiraffe){
        [self specialSightOfGiraffe:avatarMazeCell];
    }
    else if(self.mazeAvatar.avatarType == mazeAvatarSnail){
        [self straightSightOfAvatar:avatarMazeCell];
        [self.mazeAvatar mazeAvatarSnailMarkAllTrailMazeCellToVisiable];
    }
    else if(self.mazeAvatar.avatarType == mazeAvatarSunday){
        //do nothing, dont draw maze
        return;
    }
    
    if (self.mist != nil) {
        [self.mist removeFromParent];
        self.mist = nil;
    }
    [self drawMistWithUIBezierPath];
    [self restoreMist:self.visibleCells];
}



/**
 *  Loop throught all cells, if its hasMist == YES, then draw a square stroke on top of it
 *  Use one path to draw all mists
 */
-(void)drawMistWithUIBezierPath{
    SKShapeNode *square = [SKShapeNode node];
    UIBezierPath* wallPath = [[UIBezierPath alloc] init];
    //from origin point, draw bottom line
    
    MazeCell *temp;
    for (int h = 0; h < self.theMaze.mazeGraph.height; h++) {
        for (int w = 0; w < self.theMaze.mazeGraph.width; w++) {
            // move the drawing head to the center point locate on this cell (w,h)
            [wallPath moveToPoint:
                CGPointMake( w * squareLength, squareLength/2 + h * squareLength)
             ];
            temp = [self.theMaze.mazeGraph getCellAtX:w y:h];
            if (temp.hasMist == YES) {
                //draw a dot here, a fatty path like a square that covers a maze cell
                [wallPath addLineToPoint:
                    CGPointMake(squareLength + w * squareLength, squareLength/2 + h * squareLength)
                 ];
            }
        }
    }
    square.path = [wallPath CGPath];
    square.lineWidth = squareLength*1.1;
    square.strokeColor = [SKColor blackColor];
    self.mist = square;
    [self addChild:self.mist];

}

-(void)restoreMist:(NSMutableSet *)visibleCells{
    for (MazeCell *cell in visibleCells) {
        cell.hasMist = YES;
    }
    [visibleCells removeAllObjects];
}

/**
 *  calculate the sight of avatar at its location, mark all the visable aera with cell.hasMist = YES
 *
 *  @param avatarMazeCell location of avatar, avatarMazeCell
 */
-(void)straightSightOfAvatar:(MazeCell *)avatarMazeCell{
    avatarMazeCell.hasMist = NO;
    [self.visibleCells addObject:avatarMazeCell];
    
    // every direction need to re-assign the pointer to origin(avatarMazeCell)
    MazeCell *mazeCell = avatarMazeCell;
    while ((mazeCell.wallOpenBitMask & TopWallOpen)) {
        mazeCell =  [self.theMaze.mazeGraph getCellAtX:mazeCell.x y:mazeCell.y+1];
        mazeCell.hasMist = NO;
        [self.visibleCells addObject:mazeCell];
        if (!(mazeCell.wallOpenBitMask & TopWallOpen)) {
            break;
        }
    }
    
    mazeCell = avatarMazeCell;
    while ((mazeCell.wallOpenBitMask & LeftWallOpen) ) {
        mazeCell =  [self.theMaze.mazeGraph getCellAtX:mazeCell.x-1 y:mazeCell.y];
        mazeCell.hasMist = NO;
        [self.visibleCells addObject:mazeCell];
        if (!(mazeCell.wallOpenBitMask & LeftWallOpen)) {
            break;
        }
    }
    
    mazeCell = avatarMazeCell;
    while ((mazeCell.wallOpenBitMask & BottomWallOpen) ) {
        mazeCell =  [self.theMaze.mazeGraph getCellAtX:mazeCell.x y:mazeCell.y-1];
        mazeCell.hasMist = NO;
        [self.visibleCells addObject:mazeCell];
        if (!(mazeCell.wallOpenBitMask & BottomWallOpen)) {
            break;
        }
    }
    mazeCell = avatarMazeCell;
    while ((mazeCell.wallOpenBitMask & RightWallOpen) ) {
        mazeCell =  [self.theMaze.mazeGraph getCellAtX:mazeCell.x+1 y:mazeCell.y];
        mazeCell.hasMist = NO;
        [self.visibleCells addObject:mazeCell];
        if (!(mazeCell.wallOpenBitMask & RightWallOpen)) {
            break;
        }
    }
    
}

-(void)specialSightOfGiraffe:(MazeCell *)avatarMazeCell{
    avatarMazeCell.hasMist = NO;
    [self.visibleCells removeAllObjects];
    [self.visibleCells addObject:avatarMazeCell];
    
    // every direction need to re-assign the pointer to origin(avatarMazeCell)
    MazeCell *mazeCell = avatarMazeCell;
    while ((mazeCell.wallOpenBitMask & TopWallOpen)) {
        mazeCell =  [self.theMaze.mazeGraph getCellAtX:mazeCell.x y:mazeCell.y+1];
        mazeCell.hasMist = NO;
        [self.visibleCells addObject:mazeCell];
        if (!(mazeCell.wallOpenBitMask & TopWallOpen)) {
            break;
        }
    }
    
    mazeCell = avatarMazeCell;
    while ((mazeCell.wallOpenBitMask & LeftWallOpen) ) {
        mazeCell =  [self.theMaze.mazeGraph getCellAtX:mazeCell.x-1 y:mazeCell.y];
        mazeCell.hasMist = NO;
        [self.visibleCells addObject:mazeCell];
        if (!(mazeCell.wallOpenBitMask & LeftWallOpen)) {
            break;
        }
    }
    
    mazeCell = avatarMazeCell;
    while ((mazeCell.wallOpenBitMask & BottomWallOpen) ) {
        mazeCell =  [self.theMaze.mazeGraph getCellAtX:mazeCell.x y:mazeCell.y-1];
        mazeCell.hasMist = NO;
        [self.visibleCells addObject:mazeCell];
        if (!(mazeCell.wallOpenBitMask & BottomWallOpen)) {
            break;
        }
    }
    mazeCell = avatarMazeCell;
    while ((mazeCell.wallOpenBitMask & RightWallOpen) ) {
        mazeCell =  [self.theMaze.mazeGraph getCellAtX:mazeCell.x+1 y:mazeCell.y];
        mazeCell.hasMist = NO;
        [self.visibleCells addObject:mazeCell];
        if (!(mazeCell.wallOpenBitMask & RightWallOpen)) {
            break;
        }
    }
    
    //finally, different from the default straight sight, calculate surround vision, 8 total for now
    // up
    mazeCell =  [self.theMaze.mazeGraph getCellAtX:avatarMazeCell.x y:avatarMazeCell.y+1];
    if (mazeCell) {
        mazeCell.hasMist = NO;
        [self.visibleCells addObject:mazeCell];
    }
    
    // up-left
    mazeCell =  [self.theMaze.mazeGraph getCellAtX:avatarMazeCell.x-1 y:avatarMazeCell.y+1];
    if (mazeCell) {
        mazeCell.hasMist = NO;
        [self.visibleCells addObject:mazeCell];
    }
    
    // left
    mazeCell =  [self.theMaze.mazeGraph getCellAtX:avatarMazeCell.x-1 y:avatarMazeCell.y];
    if (mazeCell) {
        mazeCell.hasMist = NO;
        [self.visibleCells addObject:mazeCell];
    }
    
    // left-down
    mazeCell =  [self.theMaze.mazeGraph getCellAtX:avatarMazeCell.x-1 y:avatarMazeCell.y-1];
    if (mazeCell) {
        mazeCell.hasMist = NO;
        [self.visibleCells addObject:mazeCell];
    }
    
    // down
    mazeCell =  [self.theMaze.mazeGraph getCellAtX:avatarMazeCell.x y:avatarMazeCell.y-1];
    if (mazeCell) {
        mazeCell.hasMist = NO;
        [self.visibleCells addObject:mazeCell];
    }
    
    // down-right
    mazeCell =  [self.theMaze.mazeGraph getCellAtX:avatarMazeCell.x+1 y:avatarMazeCell.y-1];
    if (mazeCell) {
        mazeCell.hasMist = NO;
        [self.visibleCells addObject:mazeCell];
    }
    
    // right
    mazeCell =  [self.theMaze.mazeGraph getCellAtX:avatarMazeCell.x+1 y:avatarMazeCell.y];
    if (mazeCell) {
        mazeCell.hasMist = NO;
        [self.visibleCells addObject:mazeCell];
    }
    
    // right-up
    mazeCell =  [self.theMaze.mazeGraph getCellAtX:avatarMazeCell.x+1 y:avatarMazeCell.y+1];
    if (mazeCell) {
        mazeCell.hasMist = NO;
        [self.visibleCells addObject:mazeCell];
    }
}

-(void)calculateAvatarNodePositionWithAvatarCell{
    self.avatar.position = CGPointMake(squareLength/2 + self.avatarMazeCell.x * squareLength, squareLength/2 + self.avatarMazeCell.y * squareLength);
}

-(void)mazeAvatarBeforeMove{
    if (self.mazeAvatar.avatarType == mazeAvatarBlackBox) {
    }
}
-(void)mazeAvatarIsMoving{
    if (self.mazeAvatar.avatarType == mazeAvatarBlackBox) {
        // self.mazeAvatar mazeAvatarBlackBoxStepAt:
    }
    else if(self.mazeAvatar.avatarType == mazeAvatarSnail){
        [self.mazeAvatar mazeAvatarSnailAddAMazeCell:self.avatarMazeCell];
    }
}
-(void)mazeAvatarDidMove{
    if (ZenDebug >= 3) {
        NSLog(@"MazeScene:mazeAvatarDidMove: (%i, %i)", self.avatarMazeCell.x, self.avatarMazeCell.y);
    }
    if (self.avatarMazeCell.x == self.theMaze.mazeGraph.width - 1 && self.avatarMazeCell.y == self.theMaze.mazeGraph.height-1) {
        // game ends
        [self mazeGameEnd];
        
    }
    if (self.mazeAvatar.avatarType == mazeAvatarBlackBox) {
        [self.mazeAvatar mazeAvatarBlackBoxStepAt:self.avatarMazeCell];
    }
}
-(void)mazeAvatarInvokeSkill{
    if (self.mazeAvatar.avatarType == mazeAvatarBlackBox) {
        self.avatarMazeCell = [self.mazeAvatar mazeAvatarBlackBoxUndoACell];
        [self calculateAvatarNodePositionWithAvatarCell];
        [self drawMistAsOneNodeWithItsSightWithAvatarMazeCell:self.avatarMazeCell];
    }
}

-(void)mazeGameEnd{
    id<MazeSceneGameConditionDelegate> delegate = self.gameConditionDelegate;
    NSLog(@"mazeGameEnd delegate");
    if ([delegate respondsToSelector:@selector(mazeSceneGameEnds:)]) {
        NSLog(@"responds to selector");
        [delegate mazeSceneGameEnds:@"Game Over"];
    }
}

@end