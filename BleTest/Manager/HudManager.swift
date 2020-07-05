//
//  HubManager.swift
//  BleTest
//
//  Created by Jay on 2020/7/4.
//  Copyright © 2020 Null. All rights reserved.
//

import Foundation
import MBProgressHUD

class HudManager {
    static let shared = HudManager()

    var hud: MBProgressHUD?
    
    func showSimpleHUD(toView: UIView, text:String, detailText:String?) {
        DispatchQueue.main.async {
            self.hud = MBProgressHUD.showAdded(to: toView, animated: true)
            self.hud!.contentColor = .white
            self.hud!.bezelView.color = UIColor.black.withAlphaComponent(0.4)
            self.hud!.bezelView.style = .solidColor
            self.hud!.label.text = text
            if detailText != nil {
                self.hud!.detailsLabel.text = detailText!
            }
        }
    }

    func hideHUD(){
        guard let hud = self.hud else {
            assertionFailure("HUD ERROR")
            return
        }
        DispatchQueue.main.async {
            hud.hide(animated: true)
        }
    }

    func showSimpleHUDWithTime(toView: UIView, text:String, detailText:String?, delayTime: TimeInterval) {
        DispatchQueue.main.async {
            self.hud = MBProgressHUD.showAdded(to: toView, animated: true)
            self.hud!.contentColor = .white
            self.hud!.bezelView.color = UIColor.black.withAlphaComponent(0.4)
            self.hud!.bezelView.style = .solidColor
            self.hud!.label.text = text
            if detailText != nil {
                self.hud!.detailsLabel.text = detailText!
            }
            self.hud!.hide(animated: true, afterDelay: delayTime)
        }
    }
}
