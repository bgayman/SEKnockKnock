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
    if var message = request.query["message"]?.first, var uuid = request.query["uuid"]?.first
    {
        let priorState = faceVC.conversations[uuid]!.currentState
        message = message.stringByReplacingOccurrencesOfString("+", withString: " ")
        faceVC.receive(message, uuid: uuid)
        faceVC.transitionFromState(priorState, toState: faceVC.conversations[uuid]!.currentState, withUUID: uuid)
        if let emotion = faceVC.responseDicationary[uuid]!["emotion"]
        {
            return Action<AnyContent>.render(emotion, context: faceVC.responseDicationary[uuid]!)
        }
        else
        {
            faceVC.conversations[uuid]!.transitionObserver = { oldState, newState in
                faceVC.transitionFromState(oldState, toState: newState, withUUID: uuid)
            }
            faceVC.transitionFromState(.WaitingForKnock, toState: .ProcessingKnock(knock: message), withUUID: uuid)
            return Action<AnyContent>.render("Knock", context: faceVC.responseDicationary[uuid]!)
        }
    }
    else
    {
        let uuid = faceVC.transitionFromState(.WaitingForKnock, toState: .WaitingForKnock, withUUID: nil)
        return Action<AnyContent>.render("Knock", context: faceVC.responseDicationary[uuid!])
    }

}

app.get("/hello") { request in
    return Action.ok(AnyContent(str: "<h1>Hello Express!!!</h1>", contentType: "text/html"))
}

app.run()