//
//  Sector.swift
//  SportFan
//
//  Created by Irina Galata on 01.09.22.
//  Copyright © 2022 Ray Wenderlich. All rights reserved.
//

import SwiftUI

struct Sector: Shape {
  @Binding var tribunes: [Int: [Tribune]]
  var index: Int
  var tribuneHeight: CGFloat
  var tribuneWidth: CGFloat
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
      tribunes[index] = await computeTribunes(at: rect, with: corner)
    }

    return path
  }

  private func computeTribunes(at rect: CGRect, with corner: CGFloat) async -> [Tribune] {
    let result = Task {
      var tribunes: [Tribune] = []
      tribunes.append(contentsOf: computeRectTribunesPaths(at: rect, corner: corner))
      tribunes.append(contentsOf: computeArcTribunesPaths(at: rect, corner: corner))
      return tribunes
    }

    return await result.value
  }

  private func computeArcTribunesPaths(at rect: CGRect, corner: CGFloat) -> [Tribune] {
    let radius = corner - offset
    let innerRadius = corner - offset - tribuneHeight
    let arcLength = (.pi / 2) * radius
    let arcTribunesNum = Int(arcLength / (tribuneWidth * 1.2))
    let arcSpacing = (arcLength - tribuneWidth * CGFloat(arcTribunesNum)) / CGFloat(arcTribunesNum + 1)
    let angle = tribuneWidth / radius
    let spacingAngle = arcSpacing / radius

    let arcs: [CGFloat: CGPoint] = [
      .pi: CGPoint(x: rect.minX + corner, y: rect.minY + corner),
      3 * .pi / 2: CGPoint(x: rect.maxX - corner, y: rect.minY + corner),
      2 * .pi: CGPoint(x: rect.maxX - corner, y: rect.maxY - corner),
      5 * .pi / 2: CGPoint(x: rect.minX + corner, y: rect.maxY - corner)
    ]

    var tribunes: [Tribune] = []
    arcs.forEach { arc in
      var previousAngle = arc.key
      let center = arc.value

      (0..<arcTribunesNum).forEach { _ in
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
        tribunes.append(Tribune(path: arcTribune.path(in: CGRect.zero), seats: computeSeats(for: arcTribune)))

        previousAngle += spacingAngle + angle
      }
    }

    return tribunes
  }

  private func computeRectTribunesPaths(at rect: CGRect, corner: CGFloat) -> [Tribune] {
    let segmentWidth = rect.width - corner * 2.0
    let segmentHeight = rect.height - corner * 2.0
    let tribunesNumberH = Int(segmentWidth / tribuneWidth)
    let tribunesNumberV = Int(segmentHeight / tribuneWidth)
    let spacingH = (segmentWidth - tribuneWidth * CGFloat(tribunesNumberH)) / CGFloat(tribunesNumberH)
    let spacingV = (segmentHeight - tribuneWidth * CGFloat(tribunesNumberV)) / CGFloat(tribunesNumberV)

    var tribunes: [Tribune] = []
    (0..<tribunesNumberH).forEach { tribune in
      let x = rect.minX + (tribuneWidth + spacingH) * CGFloat(tribune) + corner + spacingH / 2
      tribunes.append(makeRectTribuneAt(x: x, y: rect.minY + offset, vertical: false, rotation: 0))
      tribunes.append(makeRectTribuneAt(x: x, y: rect.maxY - offset - tribuneHeight, vertical: false, rotation: -.pi))
    }
    (0..<tribunesNumberV).forEach { tribune in
      let y = rect.minY + (tribuneWidth + spacingV) * CGFloat(tribune) + corner + spacingV / 2
      tribunes.append(makeRectTribuneAt(x: rect.minX + offset, y: y, vertical: true, rotation: -.pi / 2.0))
      tribunes.append(makeRectTribuneAt(
        x: rect.maxX - offset - tribuneHeight,
        y: y,
        vertical: true,
        rotation: 3.0 * -.pi / 2.0
      ))
    }

    return tribunes
  }

  private func computeSeats(for tribune: CGRect, at rotation: CGFloat) -> [Seat] {
    let seatSize = tribuneHeight * 0.1
    let columnsNumber = Int(tribune.width / seatSize)
    let rowsNumber = Int(tribune.height / seatSize)
    let spacingH = CGFloat(tribune.width - seatSize * CGFloat(columnsNumber)) / CGFloat(columnsNumber)
    let spacingV = CGFloat(tribune.height - seatSize * CGFloat(rowsNumber)) / CGFloat(rowsNumber)

    var seats: [Seat] = []
    (0..<columnsNumber).forEach { column in
      (0..<rowsNumber).forEach { row in
        let x = tribune.minX + spacingH / 2.0 + (spacingH + seatSize) * CGFloat(column)
        let y = tribune.minY + spacingV / 2.0 + (spacingV + seatSize) * CGFloat(row)
        let seatRect = CGRect(x: x, y: y, width: seatSize, height: seatSize)

        seats.append(Seat(path: SeatShape(rotation: rotation).path(in: seatRect)))
      }
    }

    return seats
  }

  private func computeSeats(for arcTribune: ArcTribune) -> [Seat] {
    let seatSize = tribuneHeight * 0.1
    let rowsNumber = Int(tribuneHeight / seatSize)
    let spacingV = CGFloat(tribuneHeight - seatSize * CGFloat(rowsNumber)) / CGFloat(rowsNumber)

    var seats: [Seat] = []
    (0..<rowsNumber).forEach { row in
      let radius = arcTribune.radius - CGFloat(row) * (spacingV + seatSize) - spacingV - seatSize / 2.0
      let arcLength = abs(arcTribune.endAngle - arcTribune.startAngle) * radius
      let arcSeatsNum = Int(arcLength / (seatSize * 1.1))
      let arcSpacing = (arcLength - seatSize * CGFloat(arcSeatsNum)) / CGFloat(arcSeatsNum)
      let seatAngle = seatSize / radius
      let spacingAngle = arcSpacing / radius
      var previousAngle = arcTribune.startAngle + spacingAngle + seatAngle / 2.0

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

        seats.append(Seat(path: SeatShape(rotation: previousAngle + .pi / 2).path(in: seatRect)))

        previousAngle += spacingAngle + seatAngle
      }
    }

    return seats
  }

  private func makeRectTribuneAt(x: CGFloat, y: CGFloat, vertical: Bool, rotation: CGFloat) -> Tribune {
    let rect = CGRect(
      x: x,
      y: y,
      width: vertical ? tribuneHeight : tribuneWidth,
      height: vertical ? tribuneWidth : tribuneHeight
    )
    return Tribune(
      path: RectTribune().path(in: rect),
      seats: computeSeats(for: rect, at: rotation)
    )
  }
}

struct StadiumView_Previews: PreviewProvider {
  static var previews: some View {
    SeatingChartView(zoomed: Binding.constant(false), selectedTicketsNumber: Binding.constant(5))
      .frame(width: 400, height: 400)
  }
}

struct SeatingChart_Previews: PreviewProvider {
  static var previews: some View {
    SeatsSelectionView(event: makeEvent(for: Team(name: "Dallas Mavericks", sport: .basketball, description: "")))
  }
}
