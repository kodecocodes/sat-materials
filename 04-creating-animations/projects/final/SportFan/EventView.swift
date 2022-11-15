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

struct EventView: View {
  let event: Event

  var body: some View {
    VStack {
      AsyncImage(
        url: event.team.sport.imageURL,
        content: { image in
          image.resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .clipped()
        },
        placeholder: {
          ProgressView().frame(height: 100)
        }
      ).id(event.id)

      HStack {
        VStack(alignment: .leading) {
          Text(event.location)
            .font(.headline)
            .foregroundColor(.secondary)
          Text(event.team.name)
            .font(.title2)
            .fontWeight(.black)
            .foregroundColor(.primary)
            .lineLimit(3)
          HStack {
            Text(event.date.uppercased())
              .font(.caption)
              .foregroundColor(.secondary)
            Spacer()
            if event.ticketsLeft > 0 {
              Text("🎫 \(event.ticketsLeft) tickets left")
                .font(.caption)
                .foregroundColor(event.ticketsLeft > 200 ? .primary : .red)
            } else {
              Text("Sold out".uppercased())
                .font(.bold(.caption)())
                .foregroundColor(.red)
            }
          }
        }
        .layoutPriority(100)

        Spacer()

        if event.ticketsLeft > 0 {
          Image(systemName: "chevron.right").foregroundColor(.secondary)
        }
      }
      .padding()
    }
    .cornerRadius(10)
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(.gray.opacity(0.1), lineWidth: 1.5))
    .padding([.top, .horizontal])
  }
}
