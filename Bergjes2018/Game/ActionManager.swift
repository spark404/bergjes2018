//
//  ActionManager.swift
//  Bergjes2018
//
//  Created by Hugo Trippaers on 09/05/2018.
//  Copyright © 2018 Hugo Trippaers. All rights reserved.
//

import Foundation

class ActionManager {
    func isActionExecutable(actionId: String) -> Bool {
        let actions = PersistenceManager.loadActions() ?? []
        return !actions.contains {$0.name == actionId }
    }
    
    func registerActionExecution(actionId: String)  {
        var actions = PersistenceManager.loadActions() ?? []
        if let action = actions.first(where: { $0.name == actionId}) {
            action.executed += 1
        } else {
            actions.append(Action(name: actionId, executed: 1))
        }
        PersistenceManager.storeActions(actions: actions)
    }
    
    func resetActions() {
        PersistenceManager.storeActions(actions: [])
    }

}
