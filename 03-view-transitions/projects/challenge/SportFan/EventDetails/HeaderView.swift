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

struct HeaderView: View {
  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
  var namespace: Namespace.ID
  var event: Event
  @Binding var collapsed: Bool
  @Binding var offset: CGFloat

  var body: some View {
    ZStack {
      AsyncImage(
        url: event.team.sport.imageURL,
        content: { image in
          image.resizable()
            .scaledToFill()
            .frame(width: UIScreen.main.bounds.width)
            .frame(height: max(minHeaderHeight, headerHeight + offset))
            .clipped()
            .cornerRadius(collapsed ? 0 : cornersRadius)
            .shadow(radius: 2)
        },
        placeholder: {
          ProgressView().frame(height: headerHeight)
        }
      )
      .overlay {
        RoundedRectangle(cornerRadius: collapsed ? 0 : cornersRadius)
          .fill(.black.opacity(collapsed ? 0.4 : 0.2))
      }

      VStack(alignment: .leading) {
        HStack {
          Image(systemName: "chevron.left")
            .resizable()
            .scaledToFit()
            .frame(height: iconSizeS)
            .clipped()
            .foregroundColor(.white)
          if collapsed {
            Text(event.team.name)
              .frame(maxWidth: .infinity, alignment: .leading)
              .font(.title2)
              .fontWeight(.bold)
              .foregroundColor(.white)
              .matchedGeometryEffect(id: "title", in: namespace, properties: .position, isSource: false)
          } else {
            Spacer()
          }
        }.frame(height: 36.0)
          .padding(.top, UIApplication.safeAreaTopInset + 8.0)
          .contentShape(Rectangle())
          .onTapGesture {
            presentationMode.wrappedValue.dismiss()
          }

        Spacer()

        if collapsed {
          HStack {
            Image(uiImage: UIImage(named: "calendar")!)
              .renderingMode(.template)
              .resizable()
              .scaledToFit()
              .frame(height: iconSizeS)
              .foregroundColor(.white)
              .clipped()
              .matchedGeometryEffect(id: "icon", in: namespace, isSource: false)

            Text(event.date)
              .foregroundColor(.white)
              .font(.subheadline)
              .matchedGeometryEffect(id: "date", in: namespace, properties: .position, isSource: false)
          }.padding(.leading, spacingM)
            .padding(.bottom, spacingM)
        }
      }
      .padding(.horizontal)
    }.toolbar(.hidden)
      .frame(height: max(minHeaderHeight, headerHeight + offset))
  }
}
