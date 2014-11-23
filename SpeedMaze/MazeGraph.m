//
//  MazeGraph.m
//  SpeedMaze
//
//  Created by littlebeef on 11/21/14.
//  Copyright (c) 2014 beefSama. All rights reserved.
//

#import "MazeGraph.h"

@interface MazeGraph()


@end

@implementation MazeGraph

-(instancetype)initWithWidth:(int)width height:(int)height{
    self = [super init];
    if (self == nil) {
        return nil;
    }
    self.width = width;
    self.height = height;
    self.cells = [[NSMutableArray alloc] initWithCapacity:width];
    for (int i = 0; i < width; i++) {
        self.cells[i] = [[NSMutableArray alloc] initWithCapacity:height];
        for (int j = 0; j < height; j++) {
            self.cells[i][j] = [[MazeCell alloc]initWithX:i Y:j];
        }
    }
    self.removedEdges = [[NSMutableArray alloc] init];
    return self;
}

-(MazeCell *)getCellAtX:(int)x y:(int)y{
    if (x >= self.width || y >= self.height || x < 0 || y < 0) {
        return nil;
    }
    if (!self.cells[x]) {
        return nil;
    }
    return self.cells[x][y];
}

-(double)getCellDistanceBetween:(MazeCell *)cellA and:(MazeCell *)cellB{
    double xDist = ABS(cellA.x - cellB.x);
    double yDist = ABS(cellA.y - cellB.y);
    return sqrt(pow(xDist, 2) + pow(yDist, 2));
}

-(BOOL)areConnectedBetween:(MazeCell *)cellA and:(MazeCell *)cellB{
    if (!cellA || !cellB) {
        return NO;
    }
    // see if they are next B each other
    if (abs(cellA.x - cellB.x) > 1 || abs(cellA.y - cellB.y) > 1) {
        return NO;
    }
    
    if (!self.removedEdges.count) {
        return NO;
    }
    
    for(NSSet *cellPair in self.removedEdges){
        if ([cellPair containsObject:cellA] && [cellPair containsObject:cellB]){
            return YES;
        }
    }
    
    return NO;
}

-(NSArray *)cellUnvisitedNeighbors:(MazeCell *)cell{
    NSMutableArray *unvistedNeighbors = [NSMutableArray arrayWithObject:nil];
    for(MazeCell *unvistedCell in [self cellConnectedNeighbors:cell]){
        if (unvistedCell.visited == NO) {
            [unvistedNeighbors addObject:unvistedCell];
        }
    }
    return unvistedNeighbors;
}

-(NSArray *)cellConnectedNeighbors:(MazeCell *)cell{
    NSMutableArray *connectedNeighbors = [NSMutableArray arrayWithObject:nil];
    for(MazeCell *tempCell in [self cellNeighbors:cell]){
        if ([self areConnectedBetween:cell and:tempCell]) {
            [connectedNeighbors addObject:tempCell];
        }
    }
    return connectedNeighbors;
}

-(NSArray *)cellDisconnectedNeighbors:(MazeCell *)cell{
    NSMutableArray *disconnectedNeighbors = [NSMutableArray arrayWithObject:nil];
    for(MazeCell *tempCell in [self cellNeighbors:cell]){
        if (![self areConnectedBetween:cell and:tempCell]) {
            [disconnectedNeighbors addObject:tempCell];
        }
    }
    return disconnectedNeighbors;}

-(NSArray *)cellNeighbors:(MazeCell *)cell{
    NSMutableArray *neighbors = [NSMutableArray arrayWithObject:nil];
    MazeCell *topCell =    [self getCellAtX:cell.x       y:(cell.y - 1)];
    MazeCell *rightCell =  [self getCellAtX:(cell.x + 1) y:cell.y];
    MazeCell *bottomCell = [self getCellAtX:cell.x       y:(cell.y + 1)];
    MazeCell *leftCell =   [self getCellAtX:(cell.x - 1) y:cell.y];

    if(cell.y > 0 && topCell) {
        [neighbors addObject:topCell];
    }
    if(cell.x < self.width && rightCell) {
        [neighbors addObject:rightCell];
    }
    if(cell.y < self.height && bottomCell) {
        [neighbors addObject:bottomCell];
    }
    if(cell.x > 0 && leftCell) {
        [neighbors addObject:leftCell];
    }

    return neighbors;
}

-(void)removeEdgeBetween:(MazeCell *)cellA and:(MazeCell *)cellB{
    NSSet *edgePair = [[NSSet alloc] initWithObjects:cellA,cellB,nil];
    [self.removedEdges addObject:edgePair];
}

@end