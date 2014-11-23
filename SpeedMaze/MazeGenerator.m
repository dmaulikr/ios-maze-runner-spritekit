//
//  MazeGenerator.m
//  speed-maze
//
//  Created by littlebeef on 11/19/14.
//  Copyright (c) 2014 beefSama. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "MazeGenerator.h"
#import "MazeCell.h"
#import "MazeGraph.h"

@interface MazeGenerator()

@property(strong,nonatomic) NSMutableArray *mazeArray;
@property(strong,nonatomic) NSMutableArray *cellStack;
@property(strong,nonatomic) MazeGraph *mazeGraph;

@end

@implementation MazeGenerator

-(instancetype)init{
    self = [super init];
    if (self == nil) {
        return nil;
    }
    //self.mazeArray
    self.mazeArray = [[NSMutableArray alloc] init];
    self.cellStack = [[NSMutableArray alloc] init];
    return self;
}

-(instancetype)initMazeWithWidth:(int)width height:(int)height{
    self = [super init];
    self.mazeArray = [[NSMutableArray alloc] init];
    self.cellStack = [[NSMutableArray alloc] init];
    self.mazeGraph = [[MazeGraph alloc] initWithWidth:width height:height];
    return nil;
}

-(void)defaultRecusiveGrowMaze:(MazeCell *)mazeCell{
    [mazeCell visit];
    
    
    /*
     
     var recurse = function(cell) {
     cell.visit();
     var neighbors = self.graph.cellUnvisitedNeighbors(cell);
     if(neighbors.length > 0) {
     var randomNeighbor = neighbors[Math.floor(Math.random() * neighbors.length)];
     self.cellStack.push(cell);
     self.graph.removeEdgeBetween(cell, randomNeighbor);
     recurse(randomNeighbor);
     }
     else {
     var waitingCell = self.cellStack.pop();
     if(waitingCell) {
     recurse(waitingCell);
     }
     }
     };

     */
    
}

/* //js
 var MazeGenerator = function(rows, cols) {
	this.graph = new Graph(rows, cols);
	this.cellStack = [];
 
	var self = this;
 
    
 
	var recurse = function(cell) {
 cell.visit();
 var neighbors = self.graph.cellUnvisitedNeighbors(cell);
 if(neighbors.length > 0) {
 var randomNeighbor = neighbors[Math.floor(Math.random() * neighbors.length)];
 self.cellStack.push(cell);
 self.graph.removeEdgeBetween(cell, randomNeighbor);
 recurse(randomNeighbor);
 }
 else {
 var waitingCell = self.cellStack.pop();
 if(waitingCell) {
 recurse(waitingCell);
 }
 }
 };
 
 this.solve = function() {
 var closedSet = [];
 var startCell = this.graph.getCellAt(0, 0); // top left cell
 var targetCell = this.graph.getCellAt(this.graph.width - 1, this.graph.height - 1); // bottom right cell
 var openSet = [startCell];
 var searchCell = startCell;
 
 while(openSet.length > 0) {
 var neighbors = this.graph.cellDisconnectedNeighbors(searchCell);
 for(var i = 0; i < neighbors.length; i ++) {
 var neighbor = neighbors[i];
 if(neighbor == targetCell) {
 neighbor.parent = searchCell;
 this.path = neighbor.pathToOrigin();
 openSet = [];
 return;
 }
 if(!_.include(closedSet, neighbor)) {
 if(!_.include(openSet, neighbor)) {
 openSet.push(neighbor);
 neighbor.parent = searchCell;
 neighbor.heuristic = neighbor.score() + this.graph.getCellDistance(neighbor, targetCell);
 }
 }
 }
 closedSet.push(searchCell);
 openSet.remove(_.indexOf(openSet, searchCell));
 searchCell = null;
 
 _.each(openSet, function(cell) {
 if(!searchCell) {
 searchCell = cell;
 }
 else if(searchCell.heuristic > cell.heuristic) {
 searchCell = cell;
 }
 });
 }
 };
 
	this.generate = function() {
 var initialCell = this.graph.getCellAt(0, 0);
 recurse(initialCell);
	};
 };
 */
@end