//
//  LinkedAnimation.swift
//  SportFan
//
//  Created by Irina Galata on 13.08.22.
//  Copyright © 2022 Ray Wenderlich. All rights reserved.
//

import SwiftUI

struct LinkedAnimation {
  let type: Animation
  let duration: Double
  let action: () -> Void

  func link(to animation: LinkedAnimation, reverse: Bool) {
    withAnimation(reverse ? animation.type : type) {
      reverse ? animation.action() : action()
    }

    withAnimation(
      reverse ? type.delay(animation.duration) :
        animation.type.delay(duration)
    ) {
      reverse ? action() : animation.action()
    }
  }

  static func easeInOut(
    for duration: Double,
    action: @escaping () -> Void
  ) -> LinkedAnimation {
    return LinkedAnimation(
      type: .easeInOut(duration: duration),
      duration: duration,
      action: action
    )
  }
}
