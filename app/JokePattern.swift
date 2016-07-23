//
//  JokePattern.swift
//  KnockKnock
//
//  Created by Brad G. on 7/16/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import Foundation

public struct JokePattern
{
    public enum Face
    {
        case Laughing
        case Confused
        case Annoyed
    }
    
    public var setup: String
    
    public var punchline: String
    
    public var response: String
    
    public var face: Face
    
    public init(setup: String, punchline: String, response: String, face: Face)
    {
        self.setup = setup
        self.punchline = punchline
        self.response = response
        self.face = face
    }
}

public extension JokePattern
{
    public enum SerializationError: ErrorType
    {
        case MissingSetupString
        case MissingPuchlineString
        case MissingResponseString
        case MissingFaceString
        case UnknownFaceString(String)
    }
    
    init(d: [String: String]) throws
    {
        guard case let setup? = d["Setup"] else { throw SerializationError.MissingSetupString}
        guard case let punchline? = d["Punchline"] else { throw SerializationError.MissingPuchlineString }
        guard case let response? = d["Response"] else { throw SerializationError.MissingResponseString }
        guard case let faceString? = d["Face"] else { throw SerializationError.MissingFaceString }
        
        let face: Face
        switch faceString {
        case "Laughing":
            face = .Laughing
        case "Confused":
            face = .Confused
        case "Annoyed":
            face = .Annoyed
        default:
            throw SerializationError.UnknownFaceString(faceString)
        }
        
        self.setup = setup
        self.punchline = punchline
        self.response = response
        self.face = face
    }
    
    var dictionary: [String: String]
    {
        let faceString: String
        switch face {
        case .Laughing:
            faceString = "Laughing"
        case .Confused:
            faceString = "Confused"
        case .Annoyed:
            faceString = "Annoyed"
        }
        
        return [
            "Setup": self.setup,
            "Punchline": self.punchline,
            "Response": self.response,
            "Face": faceString
        ]
    }
}