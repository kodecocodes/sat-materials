//
//  HexView.swift
//  HoneyComb
//
//  Created by Irina Galata on 04.09.22.
//  Copyright © 2022 Ray Wenderlich. All rights reserved.
//

import SwiftUI

struct HexView: View {
  let hex: HexData
  let isSelected: Bool
  @Binding var touchedHexagon: HexData?

  let onTap: () -> Void

  var body: some View {
    ZStack {
      Circle()
        .fill(isSelected ? .green : Color(uiColor: UIColor.purple))
        .overlay(Circle().fill(touchedHexagon == hex ? .black.opacity(0.45) : .clear))
        .onTapGesture {
          onTap()
        }
        .simultaneousGesture(DragGesture(minimumDistance: 0)
          .onChanged { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
              touchedHexagon = hex
            }
          }
          .onEnded { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
              touchedHexagon = nil
            }
          })

      Text(hex.topic)
        .multilineTextAlignment(.center)
        .font(.footnote)
        .padding(4)
    }
    .shadow(radius: 4)
    .padding(4)
    .frame(width: diameter, height: diameter)
  }
}

struct HexView_Previews: PreviewProvider {
  static var previews: some View {
    HexView(
      hex: HexData(
        hex: Hex(q: 0, r: 0),
        center: .zero,
        topic: "Tech"
      ),
      isSelected: false,
      touchedHexagon: Binding.constant(nil)) { }
  }
}
