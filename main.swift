#!/usr/bin/env xcrun swift

import Foundation

class Instruction {
    enum Type {
        case Hop, Left, Right, Infect, IfEmpty, IfWall, IfRandom, IfEnemy, Go
    }
    
    init (type : Type, param : Int) {
        self.type = type
        self.param = param
    }
    
    class func makeHop() -> Instruction { return Instruction(type:Type.Hop, param:0) }
    class func makeLeft () -> Instruction { return Instruction(type:Type.Left, param:0) }
    class func makeRight () -> Instruction { return Instruction(type:Type.Right, param:0) }
    class func makeInfect () -> Instruction { return Instruction(type:Type.Infect, param:0) }
    class func makeIfEmpty (n : Int) -> Instruction { return Instruction(type:Type.IfEmpty, param:n) }
    class func makeIfWall (n : Int) -> Instruction { return Instruction(type:Type.IfWall, param:n) }
    class func makeIfRandom (n : Int) -> Instruction { return Instruction(type:Type.IfRandom, param:n) }
    class func makeIfEnemy (n : Int) -> Instruction { return Instruction(type:Type.IfEnemy, param:n) }
    class func makeGo (n : Int) -> Instruction { return Instruction(type:Type.Go, param:n) }

    func isActionInstruction () -> Bool {
        return
            self.type == Type.Hop ||
            self.type == Type.Left ||
            self.type == Type.Right ||
            self.type == Type.Infect
    }
    
    func isControlInstruciton () -> Bool {
        return !self.isActionInstruction ()
    }
    
    private(set) var type : Type
    private(set) var param : Int
}

class Species {

    init (identifier : String, instructions : [Instruction] = []) {
        self.identifier = identifier
        self.program = []
        for instruction in instructions {
            self.program.append (instruction)
        }
    }
    
    func addInstruction (instruction: Instruction) {
        program.append (instruction)
    }
    
    func getInstruction (index : Int) -> Instruction {
        assert (index < program.count)
        return program[index]
    }
    
    var identifier : String
    private var program : [Instruction]
}

class Creature {
    enum Direction {
        case North, East, South, West
        mutating func right () {
            switch self {
            case North:
                self = East
            case East:
                self = South
            case South:
                self =  West
            case West:
                self = North
            }
        }
        mutating func left () {
            switch self {
            case North:
                self = West
            case West:
                self = South
            case South:
                self = East
            case East:
                self = North
            }
        }
    }
    
    init (species : Species, delegate : Darwin, direction : Direction = Creature.Direction.North) {
        self.species = species
        self.delegate = delegate
        self.direction = direction
        self.programCounter = 0
    }
    
    func handleTurn () {
        while (true) {
            let instruction = self.species.getInstruction (self.programCounter++)
            switch instruction.type {
            case Instruction.Type.Hop:
                if self.delegate.creatureIsFacingEmpty (self) {
                    self.delegate.creatureHop (self)
                }
            case Instruction.Type.Left:
                self.direction.left ()
            case Instruction.Type.Right:
                self.direction.right ()
            case Instruction.Type.Infect:
                if let otherCreature = self.delegate.enemyInFrontOfCreature (self) {
                    self.infect (otherCreature)
                }
            case Instruction.Type.IfEmpty:
                let n = instruction.param
                if self.delegate.creatureIsFacingEmpty (self) {
                    self.programCounter = n
                }
            case Instruction.Type.IfWall:
                let n = instruction.param
                if self.delegate.creatureIsFacingWall (self) {
                    self.programCounter = n
                }
            case Instruction.Type.IfRandom:
                let n = instruction.param
                if rand () % 2 == 1 {
                    self.programCounter = n
                }
            case Instruction.Type.IfEnemy:
                let n = instruction.param
                if let creature = self.delegate.enemyInFrontOfCreature (self) {
                    self.programCounter = n
                }
            case Instruction.Type.Go:
                let n = instruction.param
                self.programCounter = n
            }
            if instruction.isActionInstruction () {
                break
            }
        }
    }
    
    func infect (otherCreature : Creature) {
        otherCreature.species = self.species
        otherCreature.programCounter = 0
    }
    
    var species : Species
    var delegate : Darwin
    var direction : Direction
    var programCounter : Int
}

class Darwin {

    init (numRows : Int, numCols : Int) {
        self.numRows = numRows
        self.numCols = numCols
        self.indexOfActiveCreature = 0
        self.board = [AnyObject](count: numRows*numCols, repeatedValue: NSNull())
    }
    
    func addCreature (creature : Creature, index : Int) {
        assert (index < self.board.count)
        if let creature = self.board[index] as? Creature { assert (false) }
        
        self.board[index] = creature
    }
    
    func addCreature (creature : Creature, point : (Int,Int)) {
        self.addCreature (creature, index: self.toIndex (point))
    }
    
    func indexOfCreature (creature : Creature) -> Int {
        if creature === board[self.indexOfActiveCreature] {
            return self.indexOfActiveCreature;
        }
        
        for i in 0 ..< board.count {
            if board[i] === creature {
                return i;
            }
        }
        return -1;
    }
    
    func run (numTurns : Int) {
        var turnNum = 0
        
        self.printBoard (turnNum)
        
        while (turnNum < numTurns) {
            var queue : [(Creature,Int)] = []
            for i in 0 ..< self.board.count {
                if let creature = self.board[i] as? Creature {
                    queue.append ((creature,i))
                }
            }
            while (!queue.isEmpty) {
                var data = queue[0]
                self.indexOfActiveCreature = data.1
                data.0.handleTurn ()
                queue.removeAtIndex (0)
            }
            self.printBoard (turnNum)
            ++turnNum
        }
    }
    
    func indexOfAdjacentSpace (creature : Creature) -> Int {
        var creatureIndex = self.indexOfCreature (creature)
        assert (creatureIndex != -1)
        var creaturePoint = toPoint (creatureIndex)
        
        switch (creature.direction) {
        case Creature.Direction.North :
            if creaturePoint.0 == 0 {
				return -1
            }
            --creaturePoint.0;
        case Creature.Direction.East :
            if creaturePoint.1 == self.numCols - 1 {
				return -1
            }
            ++creaturePoint.1;
        case Creature.Direction.South :
            if creaturePoint.0 == self.numRows - 1 {
				return -1
            }
            ++creaturePoint.0;
        case Creature.Direction.West :
            if creaturePoint.1 == 0 {
				return -1
            }
            --creaturePoint.1;
        default: assert (false)
        }
        return self.toIndex (creaturePoint)
    }
    
    func printBoard (turnNum : Int) {
        println ("Turn = \(turnNum)")
        for i in -1 ..< self.numRows {
            for j in -1 ..< self.numCols {
                if i == -1 && j == -1 {
                    print ("  ")
                } else if i == -1 {
                    print ("\(j%10)")
                } else if j == -1 {
                    print ("\(i%10) ")
                } else {
                    var index = toIndex ((i,j))
                    if let creature = self.board[index] as? Creature {
                        print ("\(creature.species.identifier)")
                    } else if let null = self.board[index] as? NSNull {
                        print ("-")
                    } else {
                        assert (false)
                    }
                }
            }
            println ()
        }
        println()
    }
    
    func toPoint(index : Int) -> (Int,Int) {
        var row = index / self.numCols
        var col = index % self.numCols
        return (row, col)
    }
    
    func toIndex(point : (Int,Int)) -> Int {
        return (point.0 * self.numCols) + point.1
    }
    
    /* creature delegate methods */
    func creatureHop (creature : Creature) {
        assert (self.creatureIsFacingEmpty (creature));
        var occupiedSpace = indexOfCreature (creature);
        var adjacentSpace = indexOfAdjacentSpace (creature);
        self.board[adjacentSpace] = self.board[occupiedSpace];
        self.board[occupiedSpace] = NSNull ();
    }
    func creatureIsFacingEmpty (creature : Creature) -> Bool {
        let adjacentSpace = self.indexOfAdjacentSpace (creature)
        if adjacentSpace != -1 {
            if let res = self.board[adjacentSpace] as? NSNull {
                return true
            }
        }
        return false
    }
    func creatureIsFacingWall (creature : Creature) -> Bool {
        let adjacentSpace = self.indexOfAdjacentSpace (creature)
        return adjacentSpace == -1
    }
    func enemyInFrontOfCreature (creature: Creature) -> Creature? {
        let adjacentSpace = self.indexOfAdjacentSpace (creature)
        if adjacentSpace != -1 {
            if let otherCreature = self.board[adjacentSpace] as? Creature {
                if creature.species !== otherCreature.species {
                    return otherCreature
                }
            }
        }
        return nil
    }
    var numRows : Int
    var numCols : Int
    var indexOfActiveCreature : Int
    var board : [AnyObject]
}

func main () {
    
    let food = Species (identifier:"f", instructions:[
        Instruction.makeLeft (),
        Instruction.makeGo (0)
    ])
    
    let hopper = Species (identifier:"h", instructions:[
        Instruction.makeHop (),
        Instruction.makeGo (0)
    ])
    
    let rover = Species (identifier:"r", instructions: [
        Instruction.makeIfEnemy (9),
        Instruction.makeIfEmpty (7),
        Instruction.makeIfRandom (5),
        Instruction.makeLeft (),
        Instruction.makeGo (0),
        Instruction.makeRight (),
        Instruction.makeGo (0),
        Instruction.makeHop (),
        Instruction.makeGo (0),
        Instruction.makeInfect (),
        Instruction.makeGo (0)
    ])
    
    let trap = Species (identifier:"t", instructions:[
        Instruction.makeIfEnemy (3),
        Instruction.makeLeft (),
        Instruction.makeGo (0),
        Instruction.makeInfect (),
        Instruction.makeGo (0)
    ])
    
    
    println ("*** Darwin 8x8 ***")
    /*
    8x8 Darwin
    Food,   facing east,  at (0, 0)
    Hopper, facing north, at (3, 3)
    Hopper, facing east,  at (3, 4)
    Hopper, facing south, at (4, 4)
    Hopper, facing west,  at (4, 3)
    Food,   facing north, at (7, 7)
    Simulate 5 moves.
    Print every grid.
    */
    
    var d1 = Darwin (numRows:8, numCols:8)
    
    d1.addCreature (
        Creature (species:food, delegate:d1, direction:Creature.Direction.East),
        point:(0,0)
    )
    
    d1.addCreature (
        Creature (species:hopper, delegate:d1, direction:Creature.Direction.North),
        point:(3,3)
    )
    
    d1.addCreature (
        Creature (species:hopper, delegate:d1, direction:Creature.Direction.East),
        point:(3,4)
    )
    
    d1.addCreature (
        Creature (species:hopper, delegate:d1, direction:Creature.Direction.South),
        point:(4,4)
    )
    
    d1.addCreature (
        Creature (species:hopper, delegate:d1, direction:Creature.Direction.West),
        point:(4,3)
    )
    
    d1.addCreature (
        Creature (species:food, delegate:d1, direction:Creature.Direction.North),
        point:(7,7)
    )

    d1.run (5)
}

main ();