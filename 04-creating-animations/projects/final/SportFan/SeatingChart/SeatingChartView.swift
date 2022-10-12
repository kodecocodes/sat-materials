//
//  StadiumView.swift
//  SportFan
//
//  Created by Irina Galata on 09.08.22.
//  Copyright © 2022 Ray Wenderlich. All rights reserved.
//

import SwiftUI

let sectorsNumber = 4

struct SeatingChartView: View {
  @State private var percentage: CGFloat = .zero
  @State private var zoom = 1.25
  @State private var rotation: Angle = .radians(.pi / 2)
  @State private var zoomAnchor = UnitPoint.center
  @State private var selectedTribune: Tribune? = nil
  @State private var field = CGRect.zero
  @State private var tribunes: [Int: [Tribune]] = [:]
  
  var body: some View {
    GeometryReader { proxy in
      ZStack {
        Field().path(in: field).trim(from: 0, to: percentage).fill(.green)
        Field().path(in: field).trim(from: 0, to: percentage).stroke(.white, lineWidth: 2)
        Stadium(field: $field, tribunes: $tribunes)
          .trim(from: 0, to: percentage)
          .stroke(.white, lineWidth: 2)
        
        ForEach(tribunes.flatMap { $0.value }, id: \.self) { tribune in
          tribune.path
            .trim(from: 0, to: percentage)
            .stroke(.white, style: StrokeStyle(lineWidth: 1, lineJoin: .round))
            .background(tribune.path
              .trim(from: 0, to: percentage)
              .fill(selectedTribune == tribune ? .white : .blue)
            )
            .onTapGesture(coordinateSpace: .named("stadium")) { tap in
              let unselected = tribune == selectedTribune
              let anchor = UnitPoint(x: tap.x / proxy.size.width,
                                     y: tap.y / proxy.size.height)
                              
              LinkedAnimation.easeInOut(for: 0.7) {
                zoom = unselected ? 1.25 : 12
              }.link(to: .easeInOut(for: 0.3) {
                selectedTribune = unselected ? nil : tribune
                zoomAnchor = unselected ? .center : anchor
              }, reverse: !unselected)
            }
        }
      }
      .rotationEffect(rotation)
      .coordinateSpace(name: "stadium")
      .scaleEffect(zoom, anchor: zoomAnchor)
      .onChange(of: tribunes) {
        if $0.keys.count == sectorsNumber {
          withAnimation(.easeInOut(duration: 1.0)) {
            percentage = 1.0
          }
        }
      }
    }
  }
}

struct Stadium: Shape {
  
  @Binding var field: CGRect
  @Binding var tribunes: [Int: [Tribune]]
  
  func path(in rect: CGRect) -> Path {
    var path = Path()
    let width = rect.width
    
    var smallestSectorFrame = CGRect.zero
    
    let widthToHeightRatio = 1.3
    let sectorDiff = width / (CGFloat(sectorsNumber) * 2)
    let tribuneHeight = sectorDiff / 3.0
    let tribuneWidth = tribuneHeight * 1.5
    
    (0..<sectorsNumber).forEach { sectorIndex in
      let sectionWidth = width - sectorDiff * Double(sectorIndex)
      let sectionHeight = width / widthToHeightRatio - sectorDiff * Double(sectorIndex)
      let offsetX = (width - sectionWidth) / 2.0
      let offsetY = (width - sectionHeight) / 2.0
      
      let sectorRect = CGRect(
        x: offsetX,
        y: offsetY,
        width: sectionWidth,
        height: sectionHeight
      )
      
      path.addPath(Sector(
        tribunes: $tribunes,
        index: sectorIndex,
        tribuneHeight: tribuneHeight,
        tribuneWidth: tribuneWidth - (tribuneWidth / CGFloat(sectorsNumber * 2)) * Double(sectorIndex),
        offset: (sectorDiff / 2 - tribuneHeight) / 2.0
      ).path(in: sectorRect))
      
      smallestSectorFrame = sectorRect
    }
    
    computeField(in: smallestSectorFrame)

    return path
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
    var path = Path()
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
    return path
  }
}

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
      var tribunes = [Tribune]()
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
    
    var tribunes = [Tribune]()
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
        
        tribunes.append(Tribune(path: ArcTribune(
          center: center,
          radius: radius,
          innerRadius: innerRadius,
          startingPoint: startingPoint,
          startingInnerPoint: startingInnerPoint,
          startAngle: previousAngle + spacingAngle,
          endAngle: previousAngle + spacingAngle + angle
        ).path(in: CGRect.zero)))
        
        previousAngle += spacingAngle + angle
      }
    }
    
    return tribunes
  }
  
  private func computeRectTribunesPaths(at rect: CGRect, corner: CGFloat) -> [Tribune] {
    let segmentWidth = rect.width - corner * 2.0
    let segmentHeight = rect.height - corner * 2.0
    let tribunesNumberH = Int(segmentWidth / tribuneWidth)
    let tribunesNumberV = Int(segmentHeight / tribuneWidth) // divided by width, as the tribunes in the vertical segments are rotated
    let spacingH = (segmentWidth - tribuneWidth * CGFloat(tribunesNumberH)) / CGFloat(tribunesNumberH)
    let spacingV = (segmentHeight - tribuneWidth * CGFloat(tribunesNumberV)) / CGFloat(tribunesNumberV)
    
    var tribunes = [Tribune]()
    (0..<tribunesNumberH).forEach { tribune in
      let x = rect.minX + (tribuneWidth + spacingH) * CGFloat(tribune) + corner + spacingH / 2
      tribunes.append(makeRectTribuneAt(x: x, y: rect.minY + offset))
      tribunes.append(makeRectTribuneAt(x: x, y: rect.maxY - offset - tribuneHeight))
    }
    (0..<tribunesNumberV).forEach { tribune in
      let y = rect.minY + (tribuneWidth + spacingV) * CGFloat(tribune) + corner + spacingV / 2
      tribunes.append(makeRectTribuneAt(x: rect.minX + offset, y: y, rotated: true))
      tribunes.append(makeRectTribuneAt(x: rect.maxX - offset - tribuneHeight, y: y, rotated: true))
    }
    
    return tribunes
  }
  
  private func makeRectTribuneAt(x: CGFloat, y: CGFloat, rotated: Bool = false) -> Tribune {
    return Tribune(path: RectTribune().path(in: CGRect(
      x: x,
      y: y,
      width: rotated ? tribuneHeight : tribuneWidth,
      height: rotated ? tribuneWidth : tribuneHeight
    )))
  }
}

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

struct StadiumView_Previews: PreviewProvider {
    static var previews: some View {
      SeatingChartView().frame(width: 400, height: 400)
    }
}

struct SeatingChart_Previews: PreviewProvider {
    static var previews: some View {
      SeatsSelectionView(event: makeEvent(for: Team(name: "Dallas Mavericks", sport: .basketball, description: "")))
    }
}

struct Tribune: Hashable, Equatable {
  var path: Path
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(path.description)
  }
}
