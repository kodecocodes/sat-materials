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

struct ShowResultView: View {
  var result: BrewResult

  let backGroundGradient = LinearGradient(
    colors: [Color("BlackRussian"), Color("DarkOliveGreen"), Color("OliveGreen")],
    startPoint: .init(x: 0.75, y: 0),
    endPoint: .init(x: 0.25, y: 1)
  )

  var body: some View {
    ZStack {
      backGroundGradient
        .ignoresSafeArea()
      VStack {
        VStack(alignment: .leading, spacing: 5) {
          HStack {
            Text("Name")
            Spacer()
            Text(result.name)
          }
          HStack {
            Text("Temperature")
            Spacer()
            Text("\(result.temperature)°F")
          }
          HStack {
            Text("Amount of Tea/Water")
            Spacer()
            Text("\(result.amountTea.formatted()) oz. / \(result.amountWarer.formatted()) oz.")
          }
          HStack {
            Text("Steeping Time")
            Spacer()
            Text(result.time, format: .number) + Text(" s")
          }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
          RoundedRectangle(cornerRadius: 20)
            .fill(
              Color("QuarterSpanishWhite")
            )
        )
        VStack {
          Text("Rating")
            .font(.title)
          RatingView(rating: .constant(result.rating))
            .tint(.yellow)
          .font(.title2)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
          RoundedRectangle(cornerRadius: 20)
            .fill(
              Color("QuarterSpanishWhite")
            )
        )
        RadarChartView(data: GraphDataPoint.fromBrewResult(
          result: result)
        )
        .background(
          RoundedRectangle(cornerRadius: 20)
            .fill(
              Color("QuarterSpanishWhite")
            )
        )
      }
      .font(.title2)
      .padding()
    }
  }
}

struct ShowResultView_Previews: PreviewProvider {
  static var previews: some View {
    ShowResultView(
      result: BrewResult.sampleResult
    )
  }
}
