//
//  FaceViewController.swift
//  KnockKnock
//
//  Created by Brad G. on 7/16/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

enum Emotion
{
    case Neutral
    case Laughing
    case Confused
    case Annoyed
}

class FaceViewController{
    let conversation = Conversation()
    var responseDicationary = [String:String]()
    
    var patterns: [JokePattern] = [
        JokePattern(setup: "boo", punchline: "cry", response: "That's a classic!", face: .Laughing),
        JokePattern(setup: "uint", punchline: "uint", response: "Umm...really?", face: .Annoyed),
        JokePattern(setup: "conoe", punchline: "homework", response: "No! way!", face: .Annoyed),
        JokePattern(setup: "mary", punchline: "christmas", response: "Hehe", face: .Laughing),
        JokePattern(setup: "orange", punchline: "let me in", response: "A classic!", face: .Laughing),
        JokePattern(setup: "adore", punchline: "between us", response: "Lol", face: .Laughing),
        JokePattern(setup: "otto", punchline: "i've got amnesia", response: "Oh", face: .Confused),
        JokePattern(setup: "noah", punchline: "good place", response: "Umm...no", face: .Annoyed)
    ]
    
    // MARK: - Methods for processing the conversation
    
    func processConversationLine(text: String)
    {
        switch self.conversation.currentState {
        case .WaitingForKnock:
            self.responseDicationary["placeholder"] = "Who's there?"
            self.conversation.transitionToState(.ProcessingKnock(knock: text))
        case .ProcessingKnock:
            fatalError("Expected to synchronously transition to .WaitingForReply")
            break
        case .WaitingForReply:
            self.responseDicationary["placeholder"] = "\(text) who?"
            self.conversation.transitionToState(.WaitingForPunchline(who: text))
        case .WaitingForPunchline(let who):
            self.conversation.transitionToState(.ProcessingPunchline(who: who, punchLine: text))
        case .ProcessingPunchline:
            fatalError("Expected to synchronously transition to response!")
            break
        case .Response:
            self.responseDicationary["placeholder"] = "Knock knock"
            self.conversation.transitionToState(.ProcessingKnock(knock: text))
        }
    }
    
    func replyWithMessage(message: String)
    {
        self.responseDicationary["response"] = message
    }
    
    // MARK: - Private helper methods
    
    func transitionFromState(oldState: Conversation.State, toState newState: Conversation.State)
    {
        switch newState {
        case .WaitingForKnock:
            self.responseDicationary = [String: String]()
            self.responseDicationary["placeholder"] = "Knock Knock"
            self.responseDicationary["emotion"] = "Knock"
            self.replyWithMessage(" ")
        case .ProcessingKnock(let knock):
            self.responseDicationary = [String: String]()
            let normalized = normalize(knock)
            if normalized.containsString("knock knock")
            {
                self.responseDicationary["emotion"] = "Knock"
                self.responseDicationary["placeholder"] = "Who's there?"
                replyWithMessage("Who's there?")
                self.conversation.transitionToState(.WaitingForReply)
            }
            else
            {
                self.responseDicationary["placeholder"] = "Knock Knock"
                self.responseDicationary["emotion"] = "Knock"
                self.replyWithMessage("I only understand\nknock, knock jokes")
                self.conversation.transitionToState(.Response(message: "I only understand\nknock, knock jokes", face: .Confused))
            }
        case .WaitingForReply:
            break
        case .WaitingForPunchline(let who):
            self.responseDicationary = [String: String]()
            replyWithMessage("\(who) who?")
            self.responseDicationary["emotion"] = "Knock"
            self.responseDicationary["placeholder"] = "\(who) who?"
        case .ProcessingPunchline(let who, let punchline):
            self.responseDicationary = [String: String]()
            replyWithMessage("...")
            self.responseDicationary["placeholder"] = "..."
            let normalizedWho = normalize(who)
            let normalizedPunchline = normalize(punchline)
            var response: (String, JokePattern.Face)? = nil
            for pattern in patterns
            {
                if normalizedWho.containsString(normalize(pattern.setup))
                {
                    if normalizedPunchline.containsString(normalize(pattern.punchline))
                    {
                        response = (pattern.response, pattern.face)
                        break
                    }
                }
            }
            
            if let (message, face) = response
            {
                self.conversation.transitionToState(.Response(message: message, face: face))
            }
            else
            {
                self.conversation.transitionToState(.Response(message: "I don't get it", face: .Confused))
            }
        case .Response(let message, let face):
            self.showReactionWithMessage(message, face: face)
        }
    }
    
    func showReactionWithMessage(message: String, face: JokePattern.Face)
    {
        let emotion = self.jokeFaceToEmotion(face)
        
        self.replyWithMessage("...")
        
        self.replyWithMessage(message)
        switch emotion {
        case .Annoyed:
            self.responseDicationary["emotion"] = "Annoyed"
        case .Laughing:
            self.responseDicationary["emotion"] = "Laughing"
        case .Confused:
            self.responseDicationary["emotion"] = "Confused"
        case .Neutral:
            self.responseDicationary["emotion"] = "Knock"
        }
    }
    
    func jokeFaceToEmotion(face: JokePattern.Face) -> Emotion
    {
        switch face {
        case .Laughing:
            return .Laughing
        case .Annoyed:
            return .Annoyed
        case .Confused:
            return .Confused
        }
    }
    
    func returnToWaitingToKnockAfter()
    {
        self.conversation.transitionToState(.WaitingForKnock)
    }
    
    func addJokePattern(pattern: JokePattern)
    {
        var indexToRemove: Int? = nil
        for (index, p) in patterns.enumerate()
        {
            if p.setup == pattern.setup && p.punchline == pattern.punchline
            {
                indexToRemove = index
                break
            }
        }
        
        if let index = indexToRemove
        {
            patterns.removeAtIndex(index)
        }
        
        patterns.append(pattern)
    }
}

extension FaceViewController
{
    func receive(message: String)
    {
        self.processConversationLine(message)
    }
}

































