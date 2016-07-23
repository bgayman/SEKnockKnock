//
//  Utils.swift
//  KnockKnock
//
//  Created by Brad G. on 7/16/16.
//  Copyright © 2016 Brad G. All rights reserved.
//

import Foundation

public func flipACoin() -> Bool
{
    return arc4random_uniform(2) == 0
}

public func after(interval: NSTimeInterval, work: () -> ())
{
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(interval * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), work)
}

public func randomInterval(lowerBound: NSTimeInterval, upperBound: NSTimeInterval) -> NSTimeInterval
{
    let fixedPoint: NSTimeInterval = 1000
    let fixedLowerBound = Int(lowerBound * fixedPoint)
    let fixedUpperBound = Int(upperBound * fixedPoint)
    let delta = fixedUpperBound - fixedLowerBound
    let adjustment = Int(arc4random_uniform(UInt32(delta)))
    let result = lowerBound + NSTimeInterval(adjustment)/fixedPoint
    return result
}

public func normalize(text: String) -> String
{
    return tokenize(convertToLatin(text)).joinWithSeparator(" ")
}

public func tokenize(text: String) -> [String]
{
    let allowedCharacterSet = NSCharacterSet.alphanumericCharacterSet().invertedSet
    let split: [String] = text.componentsSeparatedByCharactersInSet(allowedCharacterSet)
    let nonEmpty: [String] = split.filter { $0 != ""}
    let lowercased: [String] = nonEmpty.map { w in w.lowercaseString}
    return lowercased
}

public func convertToLatin(text: String) -> String
{
    let mutableString = NSMutableString(string: text) as CFMutableString
    CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
    CFStringTransform(mutableString, nil, kCFStringTransformStripCombiningMarks, false)
    let result = String(mutableString)
    return result
}