//
//  Created by Julio Bertolacini on 02/08/17.
//  Copyright © 2017 Julio Bertolacini Organization. All rights reserved.
//

import UIKit
import ReSwift

class ViewController: UIViewController, StoreSubscriber {
    
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var placeholder1: UILabel!
    @IBOutlet weak var placeholder2: UILabel!
    
    @IBAction func rockButton(_ sender: Any) {
        store.dispatch(ChooseWeaponAction(weapon: .rock))
    }
    
    @IBAction func paperButton(_ sender: Any) {
        store.dispatch(ChooseWeaponAction(weapon: .paper))
    }
    
    @IBAction func scissorsButton(_ sender: Any) {
        store.dispatch(ChooseWeaponAction(weapon: .scissors))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.subscribe(self)
    }
    
    func newState(state: AppState) {
        
        message.text = state.message.rawValue
        
        if state.player2Play.chosen {
            placeholder1.text = state.player1Play.weapon?.rawValue
            placeholder2.text = state.player2Play.weapon?.rawValue
        } else {
            placeholder1.text = state.player1Play.chosen ? "chosen" : ""
        }
    }
}
