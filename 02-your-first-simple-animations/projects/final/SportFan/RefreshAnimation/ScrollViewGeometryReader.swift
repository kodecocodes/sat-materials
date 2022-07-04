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

struct ScrollViewGeometryReader: View {
  @Binding var pullToRefresh: PullToRefresh
  let update: () async -> Void

  @State private var startOffset: CGFloat = 0

  var body: some View {
    GeometryReader<Color> { proxy in
      DispatchQueue.main.async {
        calculateOffset(from: proxy)
      }
      return Color.clear
    }.onAppear {
      Task {
        await update()
      }
    }
  }

  private func calculateOffset(from proxy: GeometryProxy) {
    let currentOffset = proxy.frame(in: .global).minY
    
    switch pullToRefresh.state {
    case .idle:
      startOffset = currentOffset
      pullToRefresh.state = .pulling
    case .pulling where pullToRefresh.progress < 1:
      pullToRefresh.progress = min(1, (currentOffset - startOffset) / maxOffset)
    case .pulling:
      pullToRefresh.state = .ongoing
      pullToRefresh.progress = 0
      triggerUpdate()
    default: return
    }
  }
  
  private func triggerUpdate() {
    Task {
      await update()
      pullToRefresh.state = .preparingToFinish
      after(timeForTheBallToReturn) {
        pullToRefresh.state = .finishing
      }
      after(timeForTheBallToRollOut) {
        pullToRefresh.state = .idle
        startOffset = 0
      }
    }
  }
}

struct PullToRefresh: Equatable {
  var progress: Double
  var state: AnimationState
}

enum AnimationState: Int, Comparable {
  static func < (lhs: AnimationState, rhs: AnimationState) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
  
  case idle = 0, pulling, ongoing, preparingToFinish, finishing
}

extension PullToRefresh {
  init() {
    self.init(progress: 0, state: .idle)
  }
}

func after(_ seconds: Double, execute: @escaping () -> Void) {
  DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
    execute()
  }
}
