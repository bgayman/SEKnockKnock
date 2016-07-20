
//
//  Conversation.swift
//  KnockKnock
//
//  Created by Brad G. on 7/16/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import Foundation

class Conversation
{
    enum State
    {
        case WaitingForKnock
        case ProcessingKnock(knock: String)
        case WaitingForReply
        case WaitingForPunchline(who: String)
        case ProcessingPunchline(who: String, punchLine: String)
        case Response(message: String, face:JokePattern.Face)
    }
    
    private(set) var currentState: State = .WaitingForKnock
    {
        didSet
        {
            self.generation += 1
        }
    }
    
    private(set) var generation: Int = 0
    
    func transitionToState(nextState: State)
    {
        let oldState = self.currentState
        self.currentState = nextState
        self.transitionObserver?(oldState: oldState, newState: currentState)
    }
    
    var transitionObserver: ((oldState: State, newState: State) -> ())? = nil
}

extension Conversation.State
{
    func canTransitionToState(nextState: Conversation.State) -> Bool
    {
        switch (self, nextState) {
        case (.WaitingForKnock, .ProcessingKnock),
             (.ProcessingKnock, .WaitingForReply),
             (.ProcessingKnock, .Response(_, .Confused)),
             (.WaitingForReply, .WaitingForPunchline),
             (.WaitingForPunchline, .ProcessingPunchline),
             (.ProcessingPunchline, .Response),
             (.Response, .WaitingForKnock),
             (.Response, .ProcessingKnock):
            return true
        default:
            return false
        }
    }
}
