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

struct TicketView: View {
  let info: TicketsInfo

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 4) {
        Text(info.type)
          .font(.title3)
          .fontWeight(.heavy)
          .lineLimit(2)
          .foregroundColor(Constants.orange)

        Text(info.left > 0 ? "🎫 Tickets left \(info.left)" : "SOLD OUT")
          .font(.caption)
          .fontWeight(.medium)
          .lineLimit(2)
          .foregroundColor(.primary)

        Text("💵 From $\(info.price)")
          .font(.caption)
      }
      .padding(.leading, Constants.spacingL)
    }
    .frame(height: 100)
    .background(Image("ticket")
      .resizable()
      .frame(width: UIScreen.halfWidth * 0.9, height: 100)
      .scaledToFill()
      .clipped()
      .shadow(radius: 0.5)
      )
      .padding([.horizontal])
  }
}

struct TicketView_Previews: PreviewProvider {
  static var previews: some View {
    TicketView(info: TicketsInfo(type: "Category 1", price: 345, left: 23))
  }
}
