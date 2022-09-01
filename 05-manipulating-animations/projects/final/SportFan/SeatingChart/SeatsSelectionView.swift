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

struct SeatsSelectionView: View {
  @State private var stadiumZoomed = false
  @State private var selectedTicketsNumber: Int = 0
  @State private var ticketsPurchased = false

  var event: Event

  var body: some View {
    VStack {
      if !stadiumZoomed {
        VStack {
          Text(event.team.name)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.title2)
            .fontWeight(.black)
            .foregroundColor(.white)
            .padding([.top, .horizontal])
            .shadow(radius: 2)
            .zIndex(1)

          HStack {
            Text(event.date)
              .font(.subheadline)
              .foregroundColor(.white)

            Spacer()

            ZStack(alignment: .topLeading) {
              Image("cart")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(height: iconSizeL)
                .clipped()
                .foregroundColor(.white)

              if selectedTicketsNumber > 0 {
                Text("\(selectedTicketsNumber)")
                  .foregroundColor(.white)
                  .font(.caption)
                  .background {
                    Circle()
                      .fill(.red)
                      .frame(width: 16, height: 16)
                  }
                  .alignmentGuide(.leading) { _ in -20 }
                  .alignmentGuide(.top) { _ in 4 }
              }
            }
          }.padding(.horizontal)
            .shadow(radius: 2)
        }.transition(.move(edge: .top))
      }

      Spacer()

      SeatingChartView(zoomed: $stadiumZoomed, selectedTicketsNumber: $selectedTicketsNumber)
        .aspectRatio(1.0, contentMode: .fit)
        .padding()

      Spacer()

      HStack {
        Button(action: {
          if selectedTicketsNumber > 0 {
            ticketsPurchased = true
          }
        }, label: {
          Text("Buy Tickets")
            .lineLimit(1)
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background {
              RoundedRectangle(cornerRadius: 36)
                .fill(.white)
                .shadow(radius: 2)
            }
            .padding(.horizontal)
        })

        if stadiumZoomed {
          Button(action: {
            withAnimation {
              stadiumZoomed = false
            }
          }, label: {
            Image("zoom_out")
              .resizable()
              .scaledToFit()
              .frame(width: 48, height: iconSizeL)
              .clipped()
              .background {
                RoundedRectangle(cornerRadius: 36)
                  .fill(.white)
                  .frame(width: 48, height: 48)
                  .shadow(radius: 2)
              }
              .padding(.trailing)
          })
        }
      }
      .padding(.vertical, spacingM)
    }.background(orange, ignoresSafeAreaEdges: .all)
      .confirmationDialog(
        "You've bought \(selectedTicketsNumber) tickets.",
        isPresented: $ticketsPurchased,
        actions: { Button("Ok") {} },
        message: { Text("You've bought \(selectedTicketsNumber) tickets. Enjoy your time at the game!") }
      )
  }
}
