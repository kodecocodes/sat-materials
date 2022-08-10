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

struct EventDetailsView: View {
  @Namespace var namespace
  let event: Event

  @State private var upcomingEvents: [Event] = []
  @State private var offset: CGFloat = 0
  @State private var info: [TicketsInfo] = []
  @State private var collapsed = false
  @State private var properties: [TicketsInfo: (Double, Double)] = [:]
  @State var seatingChartVisible = false

  var body: some View {
    ZStack(alignment: .top) {
      VStack {
        HeaderView(
          namespace: namespace,
          event: event,
          collapsed: $collapsed,
          offset: $offset
        )
        Spacer()
        if collapsed {
          collapsedButton
        }
      }
      .zIndex(1)
      ScrollView {
        ZStack {
          HeaderGeometryReader(offset: $offset, collapsed: $collapsed)
          VStack {
            Spacer().frame(height: headerHeight)

            if !collapsed {
              Text(event.team.name)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title2)
                .fontWeight(.black)
                .foregroundColor(.primary)
                .padding()
                .matchedGeometryEffect(id: "title", in: namespace, properties: .position)
                .zIndex(2)
            }

            VStack {
              Text(event.team.description)
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.horizontal)

              EventLocationAndDate(collapsed: $collapsed, namespace: namespace, event: event)
                .zIndex(3)

              if !collapsed {
                expandedButton
                  .zIndex(4)
              }

              Text("Available Tickets")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.title3)
                .fontWeight(.black)
                .foregroundColor(.primary)
                .padding()

              LazyVGrid(columns: [GridItem(), GridItem()]) {
                ForEach(info, id: \.type) {
                  TicketView(info: $0)
                    .padding(.top, properties[$0]?.0 ?? 0)
                    .rotationEffect(.degrees(properties[$0]?.1 ?? 0))
                }
              }.padding()

              if !upcomingEvents.isEmpty {
                Text("Upcoming Events")
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .font(.title3)
                  .fontWeight(.black)
                  .foregroundColor(.primary)
                  .padding()
              }

              VStack {
                ForEach(upcomingEvents) {
                  EventView(event: $0)
                }
              }
            }
          }
        }
      }.sheet(isPresented: $seatingChartVisible) {
        SeatsSelectionView(event: event)
      }
      .onAppear {
        let info = getTicketsInfo(for: event)
        info.forEach {
          properties[$0] = (.random(in: -16.0 ..< -5.0), .random(in: -10...10))
        }
        self.info = info
        upcomingEvents = (0..<10).map { _ in makeEvent(for: event.team) }
      }
    }
    .edgesIgnoringSafeArea(.top)
  }

  var expandedButton: some View {
    Button(action: {
      seatingChartVisible = true
    }, label: {
      Text("Seating Chart")
        .lineLimit(1)
        .foregroundColor(.white)
        .frame(minWidth: UIScreen.halfWidth / 2)
        .padding(.horizontal)
        .background {
          RoundedRectangle(cornerRadius: 36)
            .fill(orange)
            .shadow(radius: 2)
            .frame(width: max(110, min(UIScreen.halfWidth * 1.5, UIScreen.halfWidth * 1.5 + offset * 2)), height: 48)
        }
        .matchedGeometryEffect(id: "button", in: namespace, properties: .position)
    })
    .padding(.vertical, spacingM)
  }

  var collapsedButton: some View {
    HStack {
      Spacer()
      Button(action: {
        seatingChartVisible = true
      }, label: {
        Image(uiImage: UIImage(named: "seats")!)
          .resizable()
          .renderingMode(.template)
          .scaledToFit()
          .frame(width: 32, height: 32)
          .foregroundColor(.white)
          .padding(.horizontal)
          .background {
            RoundedRectangle(cornerRadius: 36)
              .fill(orange)
              .shadow(radius: 2)
              .frame(width: 110, height: 48)
          }
          .matchedGeometryEffect(id: "button", in: namespace, properties: .position)
      }).padding(36)
    }
  }
}

struct EventDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    EventDetailsView(event: Event(team: teams[0], location: "Somewhere", ticketsLeft: 345))
  }
}
