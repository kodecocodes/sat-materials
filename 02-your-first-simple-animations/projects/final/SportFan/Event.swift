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

struct Event: Equatable, Identifiable, Hashable {
  static func == (lhs: Event, rhs: Event) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  let id: Int
  let team: Team
  let date: String
  let location: String
  let ticketsLeft: Int
}

extension Event {
  init(team: Team, location: String?, ticketsLeft: Int) {
    self.init(
      id: .randomId(),
      team: team,
      date: Date.random().formatted(date: .complete, time: .omitted),
      location: location ?? "",
      ticketsLeft: ticketsLeft
    )
  }
}

enum Sport: Int, CaseIterable {
  case football = 0, basketball, iceHockey, baseball, tennis
  var imageURL: URL? {
    URL(string: sportTypeImages[self.rawValue].appending("?fit=crop&w=600&q=80"))
  }
  var string: String {
    ["Football 🏈", "Basketball 🏀", "Ice Hockey 🏒", "Baseball ⚾", "Tennis 🎾"][self.rawValue]
  }
}

struct Team {
  let name: String
  let sport: Sport
  let description: String
}
