/// Copyright (c) 2022 Kodeco Inc.
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

struct FilterView: View {
  @Binding var selectedSports: Set<Sport>
  var isShown: Bool

  private let sports = Sport.allCases
  var horizontalShift = CGFloat.zero
  var verticalShift = CGFloat.zero

  private let filterTransition = AnyTransition.modifier(
    active: FilterModifier(active: true),
    identity: FilterModifier(active: false)
  )

  var body: some View {
    var horizontalShift = CGFloat.zero
    var verticalShift = CGFloat.zero

    ZStack(alignment: .topLeading) {
      if isShown {
        ForEach(sports, id: \.self) { sport in
          Button {
            onSelected(sport)
          } label: {
            item(for: sport)
              .padding(.horizontal, 4)
              .padding(.top, 8)
              .alignmentGuide(.leading) { dimension in
                // 2
                if abs(horizontalShift - dimension.width) > UIScreen.main.bounds.width {
                  // 3
                  horizontalShift = 0
                  verticalShift -= dimension.height
                }
                // 4
                let currentShift = horizontalShift
                // 5
                horizontalShift = sport == sports.last ? 0 : horizontalShift - dimension.width
                return currentShift
              }
              .alignmentGuide(.top) { _ in
                let currentShift = verticalShift
                // 2
                verticalShift = sport == sports.last ? 0 : verticalShift
                return currentShift
              }
          }
          .transition(.asymmetric(
            insertion: filterTransition,
            removal: .scale
          ))
        }
      }
    }
    .padding(.top, isShown ? 24 : 0)
  }

  func item(for sport: Sport) -> some View {
    Text(sport.string)
      .frame(height: 48)
      .foregroundColor(selectedSports.contains(sport) ? .white : .primary)
      .padding(.horizontal, 36)
      .background {
        ZStack {
          RoundedRectangle(cornerRadius: Constants.cornersRadius)
            .fill(
              selectedSports.contains(sport)
              ? Constants.orange
              : Color(uiColor: UIColor.secondarySystemBackground)
            )
            .shadow(radius: 2)
          RoundedRectangle(cornerRadius: Constants.cornersRadius)
            .strokeBorder(Constants.orange, lineWidth: 3)
        }
      }
  }

  private func onSelected(_ sport: Sport) {
    if selectedSports.contains(sport) {
      selectedSports.remove(sport)
    } else {
      selectedSports.insert(sport)
    }
  }
}

struct FilterModifier: ViewModifier {
  // 1
  var active: Bool

  // 2
  func body(content: Content) -> some View {
    content
      // 3
      .scaleEffect(active ? 0.75 : 1)
       // 4
      .rotationEffect(.degrees(active ? .random(in: -25...25) : 0), anchor: .center)
  }
}

struct FilterView_Previews: PreviewProvider {
  static var previews: some View {
    FilterView(selectedSports: .constant([]), isShown: true)
  }
}
