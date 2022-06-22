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

func fetchMoreEvents(toAppend: [Event]) async -> [Event] {
  if !toAppend.isEmpty {
    try? await Task.sleep(nanoseconds: 5_000_000_000)
  }
  let newEvents = teams.map { team in makeEvent(for: team) }

  return (toAppend + newEvents).lazy.sorted { $0.date < $1.date }
}

func makeEvent(for team: Team) -> Event {
  let ticketsLeft = Bool.random() ? Int.random(in: 0...1000) : 0
  return Event(team: team, location: venues.randomElement(), ticketsLeft: ticketsLeft)
}

extension Date {
  static func random() -> Date {
    let date = Date()
    let calendar = Calendar.current
    var dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
    guard
      let days = calendar.range(of: .day, in: .month, for: date),
      let randomDay = days.randomElement()
    else {
      return date
    }
    dateComponents.setValue(randomDay, for: .day)
    return calendar.date(from: dateComponents) ?? date
  }
}

extension Int {
  static func randomId() -> Int {
    return Int.random(in: 0...1_000_000)
  }
}

let sportTypeImages = [
  "https://images.unsplash.com/photo-1508098682722-e99c43a406b2",
  "https://images.unsplash.com/photo-1577471488278-16eec37ffcc2",
  "https://images.unsplash.com/photo-1549956847-f77eb7058468"
]

let venues = [
  "Intrust Bank Arena",
  "BOK Center",
  "Intrust Bank Arena Parking Lots",
  "BOK Center Parking Lots"
]

let teams = [
  Team(name: "Arizona Coyotes", sport: .iceHockey),
  Team(name: "Cincinnati Cyclones", sport: .iceHockey),
  Team(name: "Dallas Mavericks", sport: .basketball),
  Team(name: "Kansas City Mavericks", sport: .iceHockey),
  Team(name: "Oklahoma City Thunder", sport: .basketball),
  Team(name: "Cincinnati Bearcats", sport: .football),
  Team(name: "Tulsa Golden Hurricane", sport: .football)
]
