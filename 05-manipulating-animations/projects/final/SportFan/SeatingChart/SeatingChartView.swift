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

struct SeatingChartView: View {
  @State private var field = CGRect.zero
  @State private var tribunes: [Int: [Tribune]] = [:]
  @State private var percentage: CGFloat = 0.0
  @State private var selectedTribune: Tribune? = nil
  @State private var zoom = 1.25
  @State private var zoomAnchor = UnitPoint.center
  @GestureState private var drag: CGSize = .zero
  @State private var offset: CGSize = .zero
  @GestureState private var manualZoom = 1.0
  @GestureState private var currentRotation: Angle = .radians(0.0)
  @State var rotation = Angle(radians: .pi / 2)
  @State private var selectedSeats: [Seat] = []
  @State private var seatsPercentage: CGFloat = .zero
  @Binding var zoomed: Bool
  @Binding var selectedTicketsNumber: Int

  var dragging: some Gesture {
    DragGesture()
      .updating($drag) { currentState, gestureState, transaction in // 1
        gestureState = currentState.translation
      }
      .onEnded { // 2
        offset = offset + $0.translation
      }
  }

  var magnification: some Gesture {
    MagnificationGesture()
      .updating($manualZoom) { currentState, gestureState, transaction in
        gestureState = currentState
      }
      .onEnded {
        zoom *= $0
        withAnimation {
          zoomed = zoom > 1.25
        }
      }
  }

  var rotationGesture: some Gesture {
    RotationGesture()
      .updating($currentRotation) { currentState, gestureState, transaction in
        gestureState = .radians(currentState.radians)
      }
      .onEnded {
        rotation += $0
      }
  }

  var body: some View {
    GeometryReader { proxy in
      ZStack {
        Field().path(in: field)
          .trim(from: 0.0, to: percentage)
          .fill(.green)

        Field().path(in: field)
          .trim(from: 0.0, to: percentage)
          .stroke(.white, lineWidth: 2)

        Stadium(field: $field, tribunes: $tribunes)
          .trim(from: 0.0, to: percentage)
          .stroke(.white, lineWidth: 2)

        ForEach(tribunes.flatMap(\.value), id: \.self) { tribune in
          tribune.path
            .trim(from: 0.0, to: percentage)
            .stroke(.white, style: StrokeStyle(lineWidth: 1, lineJoin: .round))
            .background(
              tribune.path
                .trim(from: 0.0, to: percentage)
                .fill(selectedTribune == tribune ? .white : .blue)
            )
        }

        if let selectedTribune {
          ForEach(selectedTribune.seats, id: \.self) { seat in
            ZStack {
              seat.path
                .trim(from: 0, to: seatsPercentage)
                .fill(selectedSeats.contains(seat) ? .green : .blue)
              seat.path
                .trim(from: 0, to: seatsPercentage)
                .stroke(.black, lineWidth: 0.05)
            }
          }
        }
      }
      .onTapGesture { tap in
        if let selectedTribune, selectedTribune.path.contains(tap) {
          findAndSelectSeat(at: tap, in: selectedTribune)
        } else {
          findAndSelectTribune(at: tap, with: proxy)
        }
      }
      .scaleEffect(manualZoom * zoom, anchor: zoomAnchor)
      .rotationEffect(rotation + currentRotation, anchor: zoomAnchor)
      .offset(offset + drag)
      .simultaneousGesture(dragging)
      .simultaneousGesture(magnification)
      .simultaneousGesture(rotationGesture)
      .onChange(of: tribunes) {
        guard $0.keys.count == Constants.stadiumSectorsCount else { return }
        withAnimation(.easeInOut(duration: 1.0)) {
          percentage = 1.0
        }
      }
      .onChange(of: zoomed) {
        if !$0 && zoom > 1.25 {
          LinkedAnimation.easeInOut(for: 0.7) {
            zoom = 1.25
            seatsPercentage = 0.0
          }
          .link(
            to: .easeInOut(for: 0.3) {
              selectedTribune = nil
              zoomAnchor = .center
              offset = .zero
            },
            reverse: false
          )
        }
      }
    }
  }

  private func findAndSelectSeat(at point: CGPoint, in selectedTribune: Tribune) {
    guard let seat = selectedTribune.seats
      .first(where: { $0.path.boundingRect.contains(point) }) else {
      return
    } // 1

    withAnimation(.easeInOut) {
      if let index = selectedSeats.firstIndex(of: seat) {
        selectedTicketsNumber -= 1
        selectedSeats.remove(at: index)
      } else {
        selectedTicketsNumber += 1
        selectedSeats.append(seat)
      }
    }
  }

  private func findAndSelectTribune(at point: CGPoint, with proxy: GeometryProxy) {
    let tribune = tribunes.flatMap(\.value)
      .first(where: { $0.path.boundingRect.contains(point) })
    let unselected = tribune == selectedTribune
    let anchor = UnitPoint(
      x: point.x / proxy.size.width,
      y: point.y / proxy.size.height
    )

    seatsPercentage = selectedTribune == nil || !unselected ? 0.0 : 1.0

    LinkedAnimation.easeInOut(for: 0.7) {
      zoom = unselected ? 1.25 : 25
      seatsPercentage = unselected ? 0.0 : 1.0
      zoomed = !unselected
    }
    .link(
      to: .easeInOut(for: 0.3) {
        selectedTribune = unselected ? nil : tribune
        zoomAnchor = unselected ? .center : anchor
        offset = .zero
      },
      reverse: !unselected
    )
  }
}

struct Stadium: Shape {
  @Binding var field: CGRect
  @Binding var tribunes: [Int: [Tribune]]

  func path(in rect: CGRect) -> Path {
    Path { path in
      let width = rect.width

      let widthToHeightRatio = 1.3
      let sectorDiff = width / (CGFloat(Constants.stadiumSectorsCount * 2))

      let tribuneSize = CGSize(
        width: sectorDiff / 3,
        height: sectorDiff / 4.5
      )

      var smallestSectorFrame = CGRect.zero
      (0..<Constants.stadiumSectorsCount).forEach { i in
        let sectionWidth = width - sectorDiff * Double(i)
        let sectionHeight = width / widthToHeightRatio - sectorDiff * Double(i)
        let offsetX = (width - sectionWidth) / 2.0
        let offsetY = (width - sectionHeight) / 2.0

        let sectorRect = CGRect(
          x: offsetX, y: offsetY,
          width: sectionWidth, height: sectionHeight
        )

        smallestSectorFrame = sectorRect

        let tribuneWidthOffset = (tribuneSize.width / CGFloat(Constants.stadiumSectorsCount * 2)) * Double(i)
        path.addPath(Sector(
          tribunes: $tribunes,
          index: i,
          tribuneSize: CGSize(
            width: tribuneSize.width - tribuneWidthOffset,
            height: tribuneSize.height
          ),
          offset: (sectorDiff / 2 - tribuneSize.height) / 2.0
        )
        .path(in: sectorRect))
      }

      computeField(in: smallestSectorFrame)
    }
  }

  private func computeField(in rect: CGRect) {
    Task {
      field = CGRect(
        x: rect.minX + rect.width * 0.25,
        y: rect.minY + rect.height * 0.25,
        width: rect.width * 0.5,
        height: rect.height * 0.5
      )
    }
  }
}

struct Field: Shape {
  func path(in rect: CGRect) -> Path {
    Path { path in
      path.addRect(rect)
      path.move(to: CGPoint(x: rect.midX, y: rect.minY))
      path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
      path.move(to: CGPoint(x: rect.midX, y: rect.midX))
      path.addEllipse(in: CGRect(
        x: rect.midX - rect.width / 8.0,
        y: rect.midY - rect.width / 8.0,
        width: rect.width / 4.0,
        height: rect.width / 4.0)
      )
    }
  }
}

struct Tribune: Hashable, Equatable {
  var path: Path
  var seats: [Seat]

  public func hash(into hasher: inout Hasher) {
    hasher.combine(path.description)
  }
}

struct RectTribune: Shape {
  func path(in rect: CGRect) -> Path {
    Path { path in
      path.addRect(rect)
      path.closeSubpath()
    }
  }
}

struct Sector: Shape {
  @Binding var tribunes: [Int: [Tribune]]
  var index: Int
  var tribuneSize: CGSize
  var offset: CGFloat

  func path(in rect: CGRect) -> Path {
    var path = Path()
    let corner = rect.width / 4.0

    path.addRoundedRect(
      in: rect,
      cornerSize: CGSize(width: corner, height: corner),
      style: .continuous
    )

    guard !tribunes.keys.contains(where: { $0 == index }) else {
      return path
    }

    Task {
      tribunes[index] = computeTribunes(at: rect, with: corner)
    }

    return path
  }

  private func computeRectTribunesPaths(at rect: CGRect, corner: CGFloat) -> [Tribune] {
    let segmentWidth = rect.width - corner * 2.0
    let segmentHeight = rect.height - corner * 2.0
    let tribunesHorizontalCount = segmentWidth / tribuneSize.width
    let tribunesVerticalCount = segmentHeight / tribuneSize.width

    let spacingH = (segmentWidth - tribuneSize.width * tribunesHorizontalCount) / tribunesHorizontalCount
    let spacingV = (segmentHeight - tribuneSize.width * tribunesVerticalCount) / tribunesVerticalCount

    var tribunes = [Tribune]()
    (0..<Int(tribunesHorizontalCount)).forEach { i in
      let x = rect.minX + (tribuneSize.width + spacingH) * CGFloat(i) + corner + spacingH / 2
      tribunes.append(makeRectTribuneAt(
        x: x,
        y: rect.minY + offset,
        vertical: false,
        rotation: 0
      ))
      tribunes.append(makeRectTribuneAt(
        x: x, y: rect.maxY - offset - tribuneSize.height,
        vertical: false,
        rotation: -.pi
      ))
    }

    (0..<Int(tribunesVerticalCount)).forEach { i in
      let y = rect.minY + (tribuneSize.width + spacingV) * CGFloat(i) + corner + spacingV / 2
      tribunes.append(makeRectTribuneAt(
        x: rect.minX + offset,
        y: y,
        vertical: true,
        rotation: -.pi / 2.0
      ))
      tribunes.append(makeRectTribuneAt(
        x: rect.maxX - offset - tribuneSize.height,
        y: y,
        vertical: true,
        rotation: 3.0 * -.pi / 2.0
      ))
    }

    return tribunes
  }

  private func computeArcTribunesPaths(at rect: CGRect, corner: CGFloat) -> [Tribune] {
    let radius = corner - offset
    let innerRadius = corner - offset - tribuneSize.height

    let arcLength = (.pi / 2) * radius
    let arcTribunesCount = Int(arcLength / (tribuneSize.width * 1.2))

    let arcSpacing = (arcLength - tribuneSize.width * CGFloat(arcTribunesCount)) / CGFloat(arcTribunesCount + 1)
    let angle = tribuneSize.width / radius
    let spacingAngle = arcSpacing / radius

    let arcs: [CGFloat: CGPoint] = [
      .pi: CGPoint(x: rect.minX + corner, y: rect.minY + corner),
      3 * .pi / 2: CGPoint(x: rect.maxX - corner, y: rect.minY + corner),
      2 * .pi: CGPoint(x: rect.maxX - corner, y: rect.maxY - corner),
      5 * .pi / 2: CGPoint(x: rect.minX + corner, y: rect.maxY - corner)
    ]

    return arcs.reduce(into: [Tribune]()) { tribunes, arc in
      var previousAngle = arc.key
      let center = arc.value

      let arcTribunes = (0..<arcTribunesCount).map { _ in
        let startingPoint = CGPoint(
          x: center.x + radius * cos(previousAngle + spacingAngle),
          y: center.y + radius * sin(previousAngle + spacingAngle)
        )
        let startingInnerPoint = CGPoint(
          x: center.x + innerRadius * cos(previousAngle + spacingAngle + angle),
          y: center.y + innerRadius * sin(previousAngle + spacingAngle + angle)
        )

        let arcTribune = ArcTribune(
          center: center,
          radius: radius,
          innerRadius: innerRadius,
          startingPoint: startingPoint,
          startingInnerPoint: startingInnerPoint,
          startAngle: previousAngle + spacingAngle,
          endAngle: previousAngle + spacingAngle + angle
        )

        let tribune = Tribune(
          path: arcTribune.path(in: CGRect.zero),
          seats: computeSeats(for: arcTribune)
        )

        previousAngle += spacingAngle + angle

        return tribune
      }

      tribunes.append(contentsOf: arcTribunes)
    }
  }

  private func computeSeats(for arcTribune: ArcTribune) -> [Seat] {
    var seats: [Seat] = []

    let seatSize = tribuneSize.height * 0.1
    let rowsNumber = Int(tribuneSize.height / seatSize)
    let spacingV = CGFloat(tribuneSize.height - seatSize * CGFloat(rowsNumber)) / CGFloat(rowsNumber)

    (0..<rowsNumber).forEach { row in
      let radius = arcTribune.radius - CGFloat(row) * (spacingV + seatSize) - spacingV - seatSize / 2.0 // 1
      let arcLength = abs(arcTribune.endAngle - arcTribune.startAngle) * radius // 2
      let arcSeatsNum = Int(arcLength / (seatSize * 1.1)) // 3

      let arcSpacing = (arcLength - seatSize * CGFloat(arcSeatsNum)) / CGFloat(arcSeatsNum) // 1
      let seatAngle = seatSize / radius // 2
      let spacingAngle = arcSpacing / radius // 3
      var previousAngle = arcTribune.startAngle + spacingAngle + seatAngle / 2.0 // 4

      (0..<arcSeatsNum).forEach { _ in
        let seatCenter = CGPoint(
          x: arcTribune.center.x + radius * cos(previousAngle),
          y: arcTribune.center.y + radius * sin(previousAngle)
        )

        let seatRect = CGRect(
          x: seatCenter.x - seatSize / 2,
          y: seatCenter.y - seatSize / 2,
          width: seatSize,
          height: seatSize
        )

        seats.append(
          Seat(
            path: SeatShape(rotation: previousAngle + .pi / 2)
              .path(in: seatRect)
          )
        )

        previousAngle += spacingAngle + seatAngle
      }
    }

    return seats
  }

  private func makeRectTribuneAt(
    x: CGFloat, y: CGFloat,
    vertical: Bool, rotation: CGFloat
  ) -> Tribune {
    let rect = CGRect(
      x: x,
      y: y,
      width: vertical ? tribuneSize.height : tribuneSize.width,
      height: vertical ? tribuneSize.width : tribuneSize.height
    )

    return Tribune(
      path: RectTribune().path(in: rect),
      seats: computeSeats(for: rect, at: rotation)
    )
  }

  private func computeTribunes(at rect: CGRect, with corner: CGFloat) -> [Tribune] {
    computeRectTribunesPaths(at: rect, corner: corner) +
    computeArcTribunesPaths(at: rect, corner: corner)
  }

  private func computeSeats(for tribune: CGRect, at rotation: CGFloat) -> [Seat] {
    var seats: [Seat] = []

    let seatSize = tribuneSize.height * 0.1
    let columnsNumber = Int(tribune.width / seatSize)
    let rowsNumber = Int(tribune.height / seatSize)
    let spacingH = CGFloat(tribune.width - seatSize * CGFloat(columnsNumber)) / CGFloat(columnsNumber)
    let spacingV = CGFloat(tribune.height - seatSize * CGFloat(rowsNumber)) / CGFloat(rowsNumber)

    (0..<columnsNumber).forEach { column in
      (0..<rowsNumber).forEach { row in
        let x = tribune.minX + spacingH / 2.0 + (spacingH + seatSize) * CGFloat(column)
        let y = tribune.minY + spacingV / 2.0 + (spacingV + seatSize) * CGFloat(row)

        let seatRect = CGRect(
          x: x, y: y,
          width: seatSize, height: seatSize
        )

        seats.append(Seat(
          path: SeatShape(rotation: rotation)
            .path(in: seatRect)
          )
        )
      }
    }

    return seats
  }
}

struct ArcTribune: Shape {
  var center: CGPoint
  var radius: CGFloat
  var innerRadius: CGFloat
  var startingPoint: CGPoint
  var startingInnerPoint: CGPoint
  var startAngle: CGFloat
  var endAngle: CGFloat

  func path(in rect: CGRect) -> Path {
    Path { path in
      path.move(to: startingPoint)
      path.addArc(
        center: center,
        radius: radius,
        startAngle: .radians(startAngle),
        endAngle: .radians(endAngle),
        clockwise: false
      )
      path.addLine(to: startingInnerPoint)
      path.addArc(
        center: center,
        radius: innerRadius,
        startAngle: .radians(endAngle),
        endAngle: .radians(startAngle),
        clockwise: true
      )
      path.closeSubpath()
    }
  }
}

struct SeatShape: Shape {
  let rotation: CGFloat

  func path(in rect: CGRect) -> Path {
    Path { path in
      let verticalSpacing = rect.height * 0.1
      let cornerSize = CGSize(
        width: rect.width / 15.0,
        height: rect.height / 15.0
      )
      let seatBackHeight = rect.height / 3.0 - verticalSpacing
      let squabHeight = rect.height / 2.0 - verticalSpacing
      let skewAngle = .pi / 4.0
      let skewShift = seatBackHeight / tan(skewAngle)
      let seatWidth = rect.width - skewShift

      let backRect = CGRect(
        x: 0, y: verticalSpacing,
        width: seatWidth, height: seatBackHeight
      )
      let squabRect = CGRect(
        x: 0, y: rect.height / 2.0,
        width: seatWidth, height: squabHeight
      )

      let skew = CGAffineTransform(
        a: 1, b: 0, c: -cos(skewAngle), // 1
        d: 1, tx: skewShift + verticalSpacing, ty: 0
      ) // 2

      path.addRoundedRect(
        in: backRect,
        cornerSize: cornerSize,
        transform: skew
      )
      path.addRoundedRect(in: squabRect, cornerSize: cornerSize)

      path.move(to: CGPoint(
        x: rect.width / 2.0,
        y: rect.height / 3.0
      ))
      path.addLine(to: CGPoint(
        x: rect.width / 2.0 - skewShift / 2,
        y: rect.height / 2.0
      ))

      let rotationCenter = CGPoint(x: rect.width / 2, y: rect.height / 2)
      let translationToCenter = CGAffineTransform(
        translationX: rotationCenter.x,
        y: rotationCenter.y
      )

      let initialTranslation = CGAffineTransform(
        translationX: rect.minX,
        y: rect.minY
      )

      var result = CGAffineTransformRotate(translationToCenter, rotation)
      result = CGAffineTransformTranslate(result, -rotationCenter.x, -rotationCenter.y)

      path = path.applying(result.concatenating(initialTranslation))
    }
  }
}

struct Seat: Hashable, Equatable {
  var path: Path

  public func hash(into hasher: inout Hasher) {
    hasher.combine(path.description)
  }
}

struct SeatPreview: View {
  @State var rotation: Float = 0.0
  let seatSize = 100.0

  var body: some View {
    VStack {
      ZStack {
        SeatShape(rotation: CGFloat(-rotation)).path(in: CGRect(
          x: 0, y: 0,
          width: seatSize, height: seatSize
        ))
        .fill(.blue) // 1

        SeatShape(rotation: CGFloat(-rotation)).path(
          in: CGRect(
            x: 0, y: 0,
            width: seatSize, height: seatSize
          ))
        .stroke(lineWidth: 2) // 2
      }
      .frame(width: seatSize, height: seatSize)

      Slider(value: $rotation, in: 0.0...(2 * .pi), step: .pi / 20)
      Text("\(rotation)")
    }
  }
}

struct SeatingChartView_Previews: PreviewProvider {
  @State private var percentage: CGFloat = 0.0

  static var previews: some View {
    SeatingChartView(
      zoomed: Binding.constant(false),
      selectedTicketsNumber: Binding.constant(5)
    )
    .padding()
    .background(Constants.orange)
  }
}

struct Seat_Previews: PreviewProvider {
  static var previews: some View {
    SeatPreview()
  }
}

extension CGSize {
  static func +(left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width + right.width, height: left.height + right.height)
  }
}
