/// Copyright (c) 2022 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

struct ContentView: View {
  @State var hexes: [HexData] = []
  @State var touchedHexagon: HexData?
  @State var selectedHexes: [HexData] = []

  @GestureState var drag: CGSize = .zero
  @State var dragOffset: CGSize = .zero

  var body: some View {
    VStack {
      Text("Pick topics you're most interested in:")
        .font(.subheadline)

      GeometryReader { proxy in
        ZStack {
          ForEach(hexes, id: \.self) { hex in
            let hexOrNeighboring = touchedHexagon == hex ||
            touchedHexagon?.hex.neigbouring(hex: hex.hex) == true
            let measurement = measurement(for: hex, proxy)
            let scale = (hexOrNeighboring ? measurement.size * 0.8 : measurement.size) / diameter
            HexView(
              hex: hex,
              isSelected: selectedHexes.contains(hex),
              touchedHexagon: $touchedHexagon
            ) {
              select(hex: hex)
            }
            .scaleEffect(scale)
            .offset(CGSize(
              width: hex.center.x + measurement.shift.x,
              height: hex.center.y + measurement.shift.y
            ))
            .transition(.scale)
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .offset(CGSize(
          width: drag.width + dragOffset.width,
          height: drag.height + dragOffset.height
        ))
        .simultaneousGesture(DragGesture()
          .updating($drag) { value, state, _ in
            withAnimation {
              state = value.translation
            }
          }
          .onEnded { state in
            onDragEnded(with: state)
          }
        )
        .task {
          hexes = createHexes(for: topics)
        }
      }
    }
  }

  private func onDragEnded(with state: DragGesture.Value) {
    let initialOffset = dragOffset
    dragOffset = CGSize(
      width: dragOffset.width + state.translation.width,
      height: dragOffset.height + state.translation.height
    )

    withAnimation(.easeInOut(duration: 0.5)) {
      dragOffset = CGSize(
        width: initialOffset.width + state.predictedEndTranslation.width * 1.25,
        height: initialOffset.height + state.predictedEndTranslation.height * 1.25
      )
    }
  }

  private func select(hex: HexData) {
    withAnimation(.easeInOut(duration: 0.5)) {
      dragOffset = CGSize(width: -hex.center.x, height: -hex.center.y)

      if let index = selectedHexes.firstIndex(of: hex) {
        selectedHexes.remove(at: index)
      } else {
        selectedHexes.append(hex)
        appendHexesIfNeeded(for: hex)
      }
    }
  }

  private func appendHexesIfNeeded(for hex: HexData) {
    let shouldAppend = !hex.topic.contains("subtopic")
    && !hexes.contains { $0.topic.contains("\(hex.topic)'s subtopic") }

    if shouldAppend {
      hexes.append(contentsOf: createHexes(from: hex.hex, hexes, topics: [
        "\(hex.topic)'s subtopic 1",
        "\(hex.topic)'s subtopic 2",
        "\(hex.topic)'s subtopic 3"
      ]))
    }
  }

  private func measurement(for hex: HexData, _ proxy: GeometryProxy) -> (size: CGFloat, shift: CGPoint) {
    let offsetX = hex.center.x + drag.width + dragOffset.width
    let offsetY = hex.center.y + drag.height + dragOffset.height

    let frame: CGRect = proxy.frame(in: .global)
    let excessX = abs(offsetX) + diameter - frame.width / 2
    let excessY = abs(offsetY) + diameter - frame.height / 2
    let excess = max(0, max(excessX, excessY))
    let size = max(0, diameter - 3.0 * abs(excess) / 4)

    let shift = CGPoint(
      x: offsetX > 0 ? -max(0, excessX) / 3.0 : max(0, excessX) / 3.0,
      y: offsetY > 0 ? -max(0, excessY) / 3.0 : max(0, excessY) / 3.0
    )
    return (size, shift)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
