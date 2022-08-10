//
//  StadiumView.swift
//  SportFan
//
//  Created by Irina Galata on 09.08.22.
//  Copyright © 2022 Ray Wenderlich. All rights reserved.
//

import SwiftUI

struct SeatingChartView: View {
  @State private var stadiumPathPercentage: CGFloat = .zero
  @State private var tribunesPercentage: CGFloat = .zero
  @State private var zoom = 1.25
  @State private var rotation = Angle.radians(.pi / 2)
  @State private var zoomAnchor = UnitPoint.center
  @State private var selectedTribune: Tribune? = nil
  @State private var field = CGRect.zero
  @State private var tribunes: [Int: [Tribune]] = [:]
  
  private let maxZoom = 8.0
  private let minZoom = 1.25
  
  var body: some View {
    GeometryReader { proxy in
      ZStack {
        Path {
          $0.addRect(field)
        }.trim(from: 0, to: stadiumPathPercentage).fill(.green)
        Stadium(field: $field, tribunes: $tribunes)
          .trim(from: 0, to: stadiumPathPercentage)
          .stroke(lineWidth: 2)
          .foregroundColor(.white)
          .contentShape(Rectangle())
          .onAppear {
            
            withAnimation(.easeInOut(duration: 1)) {
              self.stadiumPathPercentage = 1
            }
          }
          .shadow(radius: 16)
        
        ForEach(tribunes.flatMap { $0.value }, id: \.self) { tribune in
          tribune.path
            .trim(from: 0, to: tribunesPercentage)
            .stroke(style: StrokeStyle(lineWidth: 1, lineJoin: .round))
            .foregroundColor(.white)
            .background(tribune.path
              .trim(from: 0, to: tribunesPercentage)
              .fill(selectedTribune == tribune ? .white : .blue)
            )
            .onTapGesture(coordinateSpace: .named("stadium")) { tap in
              let selected = selectedTribune == nil
              withAnimation(.easeInOut(duration: 0.5)) {
                selectedTribune = selected ? tribune : nil
                if selected {
                  zoomAnchor = UnitPoint(x: tap.x / proxy.size.width, y: tap.y / proxy.size.width)
                }
              }
              withAnimation(.easeInOut(duration: 1)) {
                if selected {
                  zoom = maxZoom
                } else {
                  zoom = minZoom
                  zoomAnchor = .center
                }
              }
            }
            .shadow(radius: 4)
            .onAppear {
              after(0.5) {
                withAnimation(.easeInOut(duration: 1)) {
                  self.tribunesPercentage = 1
                }
              }
            }
        }
      }
      .rotationEffect(rotation, anchor: UnitPoint(
        x: field.midX / proxy.size.width,
        y: field.midY / proxy.size.height)
      )
      .scaleEffect(zoom, anchor: zoomAnchor)
      .coordinateSpace(name: "stadium")
      .onTapGesture {
        withAnimation(.easeInOut(duration: 1)) {
          zoomAnchor = .center
          zoom = 1.25
          selectedTribune = nil
        }
      }
    }
  }
}

struct Stadium: Shape {
  
  @Binding var field: CGRect
  @Binding var tribunes: [Int: [Tribune]]
  
  private let widthToHeightRatio = 1.3
  
  func path(in rect: CGRect) -> Path {
    var path = Path()
    let width = rect.width
    
    var smallestSectorFrame = CGRect.zero
    
    // Adding the sectors
    let sectionsNumber = 4
    let sectionDiff = width / (CGFloat(sectionsNumber) * 2.2)
    let tribuneHeight = sectionDiff / 3.0
    let tribuneWidth = tribuneHeight * 1.5
    
    (0..<sectionsNumber).forEach { i in
      let sectionWidth = width - sectionDiff * Double(i + 1)
      let sectionHeight = width / widthToHeightRatio - sectionDiff * Double(i + 1)
      let offsetX = (width - sectionWidth) / 2.0
      let offsetY = (width - sectionHeight) / 2.0
      
      smallestSectorFrame = CGRect(
        x: offsetX,
        y: offsetY,
        width: sectionWidth,
        height: sectionHeight
      )
      
      path.addPath(Sector(
        tribunes: $tribunes,
        index: i,
        tribuneHeight: tribuneHeight,
        tribuneWidth: tribuneWidth - (tribuneWidth / CGFloat(sectionsNumber * 2)) * Double(i),
        offset: (sectionDiff - tribuneHeight * 2.0) / 4.0 // top and bottom spacings for the top and bottom rows
      ).path(in: smallestSectorFrame))
    }
    
    computeField(in: smallestSectorFrame)
    path.addRect(field)
    path.move(to: CGPoint(x: field.midX, y: field.minY))
    path.addLine(to: CGPoint(x: field.midX, y: field.maxY))
    path.move(to: CGPoint(x: field.midX, y: field.midX))
    path.addEllipse(in: CGRect(
      x: field.midX - field.width / 8.0,
      y: field.midY - field.width / 8.0,
      width: field.width / 4.0,
      height: field.width / 4.0)
    )

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
          x: center.x + radius * cos(previousAngle + spacingAngle + angle),
          y: center.y + radius * sin(previousAngle + spacingAngle + angle)
        )
        
        tribunes.append(Tribune(path: ArcTribune(
          center: center,
          radius: radius,
          innerRadius: innerRadius,
          points: [startingPoint, startingInnerPoint],
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
    (0..<tribunesNumberH).forEach { i in
      let x = rect.minX + (tribuneWidth + spacingH) * CGFloat(i) + corner + spacingH / 2
      tribunes.append(makeRectTribuneAt(x: x, y: rect.minY + offset))
      tribunes.append(makeRectTribuneAt(x: x, y: rect.maxY - offset - tribuneHeight))
    }
    (0..<tribunesNumberV).forEach { i in
      let y = rect.minY + (tribuneWidth + spacingV) * CGFloat(i) + corner + spacingV / 2
      tribunes.append(makeRectTribuneAt(x: rect.minX + offset, y: y, rotated: true))
      tribunes.append(makeRectTribuneAt(x: rect.maxX - offset - tribuneHeight, y: y, rotated: true))
    }
    
    return tribunes
  }
  
  private func makeRectTribuneAt(x: CGFloat, y: CGFloat, rotated: Bool = false) -> Tribune {
    return Tribune(path: RectTribune(rect: CGRect(
      x: x,
      y: y,
      width: rotated ? tribuneHeight : tribuneWidth,
      height: rotated ? tribuneWidth : tribuneHeight
    )).path(in: CGRect.zero))
  }
}

struct RectTribune: Shape {
  var rect: CGRect
  
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: self.rect.maxX, y: self.rect.minY))
    path.addRect(self.rect)
    path.closeSubpath()
    return path
  }
}

struct ArcTribune: Shape {
  var center: CGPoint
  var radius: CGFloat
  var innerRadius: CGFloat
  var points: [CGPoint]
  var startAngle: CGFloat
  var endAngle: CGFloat
  
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: points[1])
    path.addArc(
      center: center,
      radius: innerRadius,
      startAngle: .radians(endAngle),
      endAngle: .radians(startAngle),
      clockwise: true
    )
    path.addLine(to: points[0])
    path.addArc(
      center: center,
      radius: radius,
      startAngle: .radians(startAngle),
      endAngle: .radians(endAngle),
      clockwise: false
    )
    path.addLine(to: points[1])
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
