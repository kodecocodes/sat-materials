//
//  TribunesAndSeats.swift
//  SportFan
//
//  Created by Irina Galata on 01.09.22.
//  Copyright © 2022 Ray Wenderlich. All rights reserved.
//

import SwiftUI

struct RectTribune: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.addRect(rect)
    path.closeSubpath()
    return path
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
    var path = Path()
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

    return path
  }
}

struct Tribune: Hashable, Equatable {
  var path: Path
  var seats: [Seat]

  public func hash(into hasher: inout Hasher) {
    hasher.combine(path.description)
  }
}

struct Seat: Hashable, Equatable {
  var path: Path

  public func hash(into hasher: inout Hasher) {
    hasher.combine(path.description)
  }
}

struct SeatShape: Shape {
  let rotation: CGFloat

  func path(in rect: CGRect) -> Path {
    var path = Path()

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

    path.move(to: CGPoint(x: rect.width / 2.0, y: rect.height / 3.0))
    path.addLine(to: CGPoint(
      x: rect.width / 2.0 - skewShift / 2,
      y: rect.height / 2.0
    ))

    let backRect = CGRect(
      x: 0, y: verticalSpacing, width: seatWidth, height: seatBackHeight
    )

    let squabRect = CGRect(
      x: 0, y: rect.height / 2.0, width: seatWidth, height: squabHeight
    )

    let skew = CGAffineTransform(a: 1, b: 0, c: -cos(skewAngle), d: 1, tx: skewShift + verticalSpacing, ty: 0)

    path.addRoundedRect(in: backRect, cornerSize: cornerSize, transform: skew)
    path.addRoundedRect(in: squabRect, cornerSize: cornerSize)

    let rotationCenter = CGPoint(x: rect.width / 2, y: rect.height / 2)
    let translationToCenter = CGAffineTransform(translationX: rotationCenter.x, y: rotationCenter.y)
    let initialTranslation = CGAffineTransform(translationX: rect.minX, y: rect.minY)
    var result = CGAffineTransformRotate(translationToCenter, rotation)
    result = CGAffineTransformTranslate(result, -rotationCenter.x, -rotationCenter.y)

    return path.applying(result.concatenating(initialTranslation))
  }
}

struct Seat_Previews: PreviewProvider {
  static var previews: some View {
    SeatPreview()
  }
}

struct SeatPreview: View {
  let seatSize = 100.0
  @State var rotation: Float = 0.0

  var body: some View {
    VStack {
      ZStack {
        Seat(path: SeatShape(rotation: CGFloat(-rotation))
          .path(in: CGRect(x: 0, y: 0, width: seatSize, height: seatSize)))
          .path.fill(.blue)
        Seat(path: SeatShape(rotation: CGFloat(-rotation))
          .path(in: CGRect(x: 0, y: 0, width: seatSize, height: seatSize)))
          .path.stroke(lineWidth: 2)
      }.frame(width: seatSize, height: seatSize)

      Slider(value: $rotation, in: 0.0...(2 * .pi), step: .pi / 20)
      Text("\(rotation)")
    }.padding()
  }
}
