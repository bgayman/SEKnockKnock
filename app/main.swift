//
//  main.swift
//
//  Copyright © 2015-2016 Daniel Leping (dileping). All rights reserved.
//

import Express

let app = express()
let faceVC = FaceViewController()

app.views.register(StencilViewEngine())

app.get("/assets/:file+", action: StaticAction(path: "public", param:"file"))

app.get("/") { (request:Request<AnyContent>)->Action<AnyContent> in
    return Action<AnyContent>.render("index", context: ["hello": "Hello,", "swift": "Swift", "express": "Express!"])
}

app.listen(9999).onSuccess { server in
    print("Express was successfully launched on port", server.port)
}

app.get("/knockknock"){ (request:Request<AnyContent>)->Action<AnyContent> in
    let priorState = faceVC.conversation.currentState
    if var message = request.query["message"]?.first
    {
        message = message.stringByReplacingOccurrencesOfString("+", withString: " ")
        print(message)
        faceVC.receive(message)
        faceVC.transitionFromState(priorState, toState: faceVC.conversation.currentState)
        print(faceVC.conversation.currentState)
        if let emotion = faceVC.responseDicationary["emotion"]
        {
            return Action<AnyContent>.render(emotion, context: faceVC.responseDicationary)
        }
        else
        {
            faceVC.conversation.transitionObserver = { oldState, newState in
                faceVC.transitionFromState(oldState, toState: newState)
            }
            faceVC.transitionFromState(.WaitingForKnock, toState: .ProcessingKnock(knock: message))
            return Action<AnyContent>.render("Knock", context: faceVC.responseDicationary)
        }
    }
    else
    {
        faceVC.conversation.transitionObserver = { oldState, newState in
            faceVC.transitionFromState(oldState, toState: newState)
        }
        faceVC.transitionFromState(.WaitingForKnock, toState: .WaitingForKnock)
        return Action<AnyContent>.render("Knock", context: faceVC.responseDicationary)
    }

}

app.get("/knockk") { (request:Request<AnyContent>)->Action<AnyContent> in
    let priorState = faceVC.conversation.currentState
    if let message = request.query["message"]?.first
    {
        faceVC.receive(message)
    }
    faceVC.transitionFromState(priorState, toState: faceVC.conversation.currentState)
    print("HERE")
    print(faceVC.responseDicationary)
    if let emotion = faceVC.responseDicationary["emotion"]
    {
        return Action<AnyContent>.render(emotion, context: faceVC.responseDicationary)
    }
    else
    {
        faceVC.conversation.transitionObserver = { oldState, newState in
            faceVC.transitionFromState(oldState, toState: newState)
        }
        faceVC.transitionFromState(.WaitingForKnock, toState: .WaitingForKnock)
        print(faceVC.responseDicationary)
        return Action<AnyContent>.render("Knock", context: faceVC.responseDicationary)
    }
}

app.get("/hello") { request in
    return Action.ok(AnyContent(str: "<h1>Hello Express!!!</h1>", contentType: "text/html"))
}

app.run()