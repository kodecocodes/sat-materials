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

  @State private var offset: CGFloat = 0
  @State private var startOffset: CGFloat = 0

  var body: some View {
    GeometryReader { proxy -> AnyView in
      DispatchQueue.main.async {
        calculateOffset(from: proxy)
      }
      return AnyView(Color.clear)
    }.onAppear {
      Task {
        await update()
      }
    }
  }

  private func calculateOffset(from proxy: GeometryProxy) {
    offset = proxy.frame(in: .global).minY

    if startOffset == 0 {
      startOffset = offset
    }

    if !pullToRefresh.started {
      pullToRefresh.progress = min(1, (offset - startOffset) / maxOffset) // progress of the user's gesture, 0...1
    }

    if offset - startOffset > maxOffset && !pullToRefresh.started {
      pullToRefresh.started = true // the refreshing view is fully expanded
      
      Task {
        await update() // 1. The content got refreshed and new items are added
        pullToRefresh.updateFinished = true // 2. The ball stops jumping and moves along the y axis back to top
        after(timeForTheBallToReturn) {
          // 3. Scroll view moves along the y axis to initial position
          // 4. The ball rolls out of the screen
          complete()
        }
        after(timeForTheBallToRollOut) {
          // 5. The view is reset to its initial positions and the animation can be repeated again
          reset()
        }
      }
    }
  }

  private func complete() {
    pullToRefresh.progress = 0
    pullToRefresh.started = false
    pullToRefresh.animationFinished = true
  }

  private func reset() {
    pullToRefresh.updateFinished = false
    pullToRefresh.animationFinished = false
  }
}

struct PullToRefresh: Equatable {
  var started: Bool
  var progress: Double
  var updateFinished: Bool
  var animationFinished: Bool
}

extension PullToRefresh {
  init() {
    self.init(started: false, progress: 0, updateFinished: false, animationFinished: false)
  }
}

func after(_ seconds: Double, execute: @escaping () -> Void) {
  DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
    execute()
  }
}
