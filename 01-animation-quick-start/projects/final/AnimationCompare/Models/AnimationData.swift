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

import Foundation
import SwiftUI

struct AnimationData: Identifiable {
  var id = UUID()
  var type: AnimationType
  // Linear and eased
  var length: Double = 1.0
  var delay: Double = 0.0
  // Spring
  var mass: Double = 1.0
  var stiffness: Double = 100.0
  var damping: Double = 10.0
  var initialVelocity: Double = 0.0
  // Interpolating Spring
  var response: Double = 0.55
  var dampingFraction: Double = 0.82

  var animationTimeFormatter: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 1
    return formatter
  }

  var description: String {
    var typeString: String
    switch type {
    case .linear:
      typeString = "Linear"
    case .easeIn:
      typeString = "Ease In"
    case .easeOut:
      typeString = "Ease Out"
    case .easeInOut:
      typeString = "Ease In/Out"
    case .spring:
      typeString = "Spring"
    case .interpolatingSpring:
      typeString = "Interpolating Spring"
    }

    let delayString = animationTimeFormatter.string(for: delay) ?? "??"
    let lengthString = animationTimeFormatter.string(for: length) ?? "??"
    let responseString = animationTimeFormatter.string(for: response) ?? "??"
    let dampingFractionString = animationTimeFormatter.string(for: dampingFraction) ?? "??"
    let massString = animationTimeFormatter.string(for: mass) ?? "??"
    let stiffnessString = animationTimeFormatter.string(for: stiffness) ?? "??"
    let dampingString = animationTimeFormatter.string(for: damping) ?? "??"

    if type == .linear || type == .easeIn || type == .easeOut || type == .easeInOut {
      return "\(typeString) Animation\nLength: \(lengthString) s Delay: \(delayString) s"
    }
    if type == .spring {
      return "\(typeString) Animation\nResponse: \(responseString) Damping Fraction \(dampingFractionString)"
    }

    // interpolating spring
    return "\(typeString) Animation\nMass: \(massString) Stiffness: \(stiffnessString) Damping: \(dampingString)"
  }
}

enum AnimationType {
  case linear
  case easeIn
  case easeOut
  case easeInOut
  case spring
  case interpolatingSpring
}
