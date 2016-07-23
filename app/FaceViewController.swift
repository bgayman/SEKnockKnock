//
//  FaceViewController.swift
//  KnockKnock
//
//  Created by Brad G. on 7/16/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import Foundation

enum Emotion
{
    case Neutral
    case Laughing
    case Confused
    case Annoyed
}

class FaceViewController{
    var conversations = [String:Conversation]()
    var responseDicationary = [String:[String:String]]()
    
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
    
    func processConversationLine(text: String, uuid: String)
    {
        guard self.conversations[uuid] != nil else { return }
        switch self.conversations[uuid]!.currentState {
        case .WaitingForKnock:
            self.responseDicationary[uuid]!["placeholder"] = "Who's there?"
            self.conversations[uuid]!.transitionToState(.ProcessingKnock(knock: text))
        case .ProcessingKnock:
            fatalError("Expected to synchronously transition to .WaitingForReply")
            break
        case .WaitingForReply:
            self.responseDicationary[uuid]!["placeholder"] = "\(text) who?"
            self.conversations[uuid]!.transitionToState(.WaitingForPunchline(who: text))
        case .WaitingForPunchline(let who):
            self.conversations[uuid]!.transitionToState(.ProcessingPunchline(who: who, punchLine: text))
        case .ProcessingPunchline:
            fatalError("Expected to synchronously transition to response!")
            break
        case .Response:
            self.responseDicationary[uuid]!["placeholder"] = "Knock knock"
            self.conversations[uuid]!.transitionToState(.ProcessingKnock(knock: text))
        }
    }
    
    func replyWithMessage(message: String, uuid: String)
    {
        self.responseDicationary[uuid]!["response"] = message
    }
    
    // MARK: - Private helper methods
    
    func transitionFromState(oldState: Conversation.State, toState newState: Conversation.State, withUUID uuid: String?) -> String?
    {
        switch newState {
        case .WaitingForKnock:
            let uuid = self.createConversation()
            self.responseDicationary[uuid]!["placeholder"] = "Knock Knock"
            self.responseDicationary[uuid]!["emotion"] = "Knock"
            self.replyWithMessage(" ", uuid: uuid)
            return uuid
        case .ProcessingKnock(let knock):
            self.responseDicationary[uuid!] = [String: String]()
            self.responseDicationary[uuid!]!["uuid"] = uuid!
            let normalized = normalize(knock)
            if normalized.containsString("knock knock")
            {
                self.responseDicationary[uuid!]!["emotion"] = "Knock"
                self.responseDicationary[uuid!]!["placeholder"] = "Who's there?"
                replyWithMessage("Who's there?", uuid: uuid!)
                self.conversations[uuid!]!.transitionToState(.WaitingForReply)
            }
            else
            {
                self.responseDicationary[uuid!]!["placeholder"] = "Knock Knock"
                self.responseDicationary[uuid!]!["emotion"] = "Knock"
                self.replyWithMessage("I only understand\nknock, knock jokes", uuid: uuid!)
                self.conversations[uuid!]!.transitionToState(.Response(message: "I only understand\nknock, knock jokes", face: .Confused))
            }
            return nil
        case .WaitingForReply:
            return nil
        case .WaitingForPunchline(let who):
            self.responseDicationary[uuid!] = [String: String]()
            replyWithMessage("\(who) who?", uuid: uuid!)
            self.responseDicationary[uuid!]!["uuid"] = uuid!
            self.responseDicationary[uuid!]!["emotion"] = "Knock"
            self.responseDicationary[uuid!]!["placeholder"] = "\(who) who?"
            return nil
        case .ProcessingPunchline(let who, let punchline):
            self.responseDicationary[uuid!] = [String: String]()
            replyWithMessage("...", uuid: uuid!)
            self.responseDicationary[uuid!]!["uuid"] = uuid!
            self.responseDicationary[uuid!]!["placeholder"] = "..."
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
                self.conversations[uuid!]!.transitionToState(.Response(message: message, face: face))
            }
            else
            {
                self.conversations[uuid!]!.transitionToState(.Response(message: "I don't get it", face: .Confused))
            }
            return nil
        case .Response(let message, let face):
            self.responseDicationary[uuid!]!["uuid"] = uuid!
            self.showReactionWithMessage(message, face: face, uuid: uuid!)
            return nil
        }
    }
    
    func showReactionWithMessage(message: String, face: JokePattern.Face, uuid: String)
    {
        let emotion = self.jokeFaceToEmotion(face)
        
        self.replyWithMessage("...", uuid: uuid)
        if var responseDict = self.responseDicationary[uuid]
        {
            self.replyWithMessage(message, uuid: uuid)
            switch emotion {
            case .Annoyed:
                responseDict["emotion"] = "Annoyed"
            case .Laughing:
                responseDict["emotion"] = "Laughing"
            case .Confused:
                responseDict["emotion"] = "Confused"
            case .Neutral:
                responseDict["emotion"] = "Knock"
            }
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
    
    func createConversation() -> String
    {
        let uuid = NSUUID()
        self.conversations[uuid.UUIDString] = Conversation()
        self.responseDicationary[uuid.UUIDString] = [String:String]()
        self.responseDicationary[uuid.UUIDString]!["uuid"] = uuid.UUIDString
        return uuid.UUIDString
    }
}

extension FaceViewController
{
    func receive(message: String, uuid: String)
    {
        self.processConversationLine(message, uuid: uuid)
    }
}

































