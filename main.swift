#!/usr/bin/env xcrun swift

import Foundation

class Instruction {
    enum Type {
        case Hop
        case Left
        case Right
        case Infect
        case IfEmpty
        case IfWall
        case IfRandom
        case IfEnemy
        case Go
    }
    
    init (type : Type, param : Int) {
        self.type = type
        self.param = param
    }
    
    class func makeHop() -> Instruction { return Instruction(type:Type.Hop, param:0) }
    class func makeLeft () -> Instruction { return Instruction(type:Type.Left, param:0) }
    class func makeRight () -> Instruction { return Instruction(type:Type.Right, param:0) }
    class func makeInfect () -> Instruction { return Instruction(type:Type.Infect, param:0) }
    class func makeIfEmpty () -> Instruction { return Instruction(type:Type.IfEmpty, param:0) }
    class func makeIfWall () -> Instruction { return Instruction(type:Type.IfWall, param:0) }
    class func makeIfRandom () -> Instruction { return Instruction(type:Type.IfRandom, param:0) }
    class func makeIfEnemy () -> Instruction { return Instruction(type:Type.IfEnemy, param:0) }

    var type : Type
    var param : Int
}

class Species {

    init (identifier : String) {
        self.identifier = identifier
        self.program = []
    }
    
    var identifier : String
    var program : [Instruction]
}

class Creature {
    enum Direction {
        case North
        case East
        case South
        case West
    }
    
    init (species : Species, delegate : Darwin, direction : Direction) {
        self.species = species
        self.delegate = delegate
        self.direction = direction
    }
    
    func handleTurn () {
        return
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

    var numRows : Int
    var numCols : Int
    var indexOfActiveCreature : Int
    var board : [Creature]
}

func main () {
    
}

main ();