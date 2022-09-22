//
//  HoneyCombGrid.swift
//  HoneyComb
//
//  Created by Irina Galata on 22.09.22.
//  Copyright © 2022 Ray Wenderlich. All rights reserved.
//

import SwiftUI

struct HoneyCombGrid: Layout {
  let hexes: [HexData]

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    return CGSize(width: proposal.width ?? .infinity, height: proposal.height ?? .infinity)
  }

  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
    subviews.enumerated().forEach { i, subview in
      let hexagon = hexes[i]
      let position = CGPoint(
        x: bounds.origin.x + hexagon.center.x + bounds.width / 2,
        y: bounds.origin.y + hexagon.center.y + bounds.height / 2
      )
      subview.place(at: position, anchor: .center, proposal: proposal)
    }
  }
}
