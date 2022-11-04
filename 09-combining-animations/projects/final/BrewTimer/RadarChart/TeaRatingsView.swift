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

struct TeaRatingsView: View {
  var ratings: [BrewResult]
  @State var selectedRating: Int = 0

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
        VStack {
          TabView(selection: $selectedRating) {
            ForEach(ratings.indices, id: \.self) { ratingIndex in
              VStack {
                Text(ratings[ratingIndex].name)
                Text("\(ratings[ratingIndex].temperature) °F")
                Text(ratings[ratingIndex].time, format: .number) + Text(" s")
                Text("\(ratings[ratingIndex].amountTea.formatted()) tsp.") +
                Text("/ \(ratings[ratingIndex].amountWater.formatted()) oz.")
                StaticRatingView(rating: ratings[ratingIndex].rating)
                  .foregroundColor(.yellow)
              }
              .tabItem {
                Text(ratings[ratingIndex].name)
              }
              .tag(ratingIndex)
            }
          }
          .tabViewStyle(.page(indexDisplayMode: .never))
          HStack {
            ForEach(ratings.indices, id: \.self) { index in
              Rectangle()
                .fill(selectedRating == index ? Color("OliveGreen") : Color("DarkOliveGreen"))
                .frame(width: 25, height: 10)
                .onTapGesture {
                  selectedRating = index
                }
            }
          }
        }
        .frame(height: 160)
        .padding(20)
        .background(
          RoundedRectangle(cornerRadius: 20)
            .fill(
              Color("QuarterSpanishWhite")
            )
        )
        Spacer()
        AnimatedRadarChart(
          time: Double(ratings[selectedRating].time),
          temperature: Double(ratings[selectedRating].temperature),
          amountWater: ratings[selectedRating].amountWater,
          amountTea: ratings[selectedRating].amountTea,
          rating: Double(ratings[selectedRating].rating)
        )
        .aspectRatio(contentMode: .fit)
        .animation(.linear, value: selectedRating)
        .padding(20)
        .background(
          RoundedRectangle(cornerRadius: 20)
            .fill(
              Color("QuarterSpanishWhite")
            )
        )
      }
      .font(.body)
      .padding()
    }
  }
}

struct TeaRatingsView_Previews: PreviewProvider {
  static var previews: some View {
    TeaRatingsView(
      ratings: BrewTime.previewObjectEvals.evaluation
    )
  }
}
