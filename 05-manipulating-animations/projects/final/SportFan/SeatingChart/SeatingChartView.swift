//
//  StadiumView.swift
//  SportFan
//
//  Created by Irina Galata on 09.08.22.
//  Copyright © 2022 Ray Wenderlich. All rights reserved.
//

import SwiftUI

struct SeatingChartView: View {
  @Binding var zoomed: Bool
  @Binding var selectedTicketsNumber: Int
  @State private var percentage: CGFloat = .zero
  @State private var seatsPercentage: CGFloat = .zero
  @State private var zoomAnchor = UnitPoint.center
  @State private var selectedTribune: Tribune?
  @State private var field = CGRect.zero
  @State private var tribunes: [Int: [Tribune]] = [:]
  @State private var selectedSeats: [Seat] = []

  @GestureState private var drag: CGSize = .zero
  @State private var offset: CGSize = .zero

  @GestureState private var manualZoom = 1.0
  @State private var zoom = 1.25

  @GestureState private var currentRotation: Angle = .radians(0.0)
  @State var rotation = Angle(radians: .pi / 2)

  var rotationGesture: some Gesture {
    RotationGesture()
      .updating($currentRotation) { currentState, gestureState, _ in
        gestureState = .radians(currentState.radians)
      }
      .onEnded {
        rotation += $0
      }
  }

  var magnification: some Gesture {
    MagnificationGesture()
      .updating($manualZoom) { currentState, gestureState, _ in
        gestureState = currentState
      }
      .onEnded {
        zoom *= $0
        withAnimation {
          zoomed = zoom > 1.25
        }
      }
  }

  var dragging: some Gesture {
    DragGesture()
      .updating($drag) { currentState, gestureState, _ in
        gestureState = currentState.translation
      }
      .onEnded {
        offset += $0.translation
      }
  }

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
        }
        if let selectedTribune = selectedTribune {
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
        if let selectedTribune = selectedTribune, selectedTribune.path.contains(tap) {
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
        if $0.keys.count == sectorsNumber {
          withAnimation(.easeInOut(duration: 1.0)) {
            percentage = 1.0
          }
        }
      }
      .onChange(of: zoomed) {
        if !$0 && zoom > 1.25 {
          LinkedAnimation
            .easeInOut(for: 0.7) {
              zoom = 1.25
              seatsPercentage = 0.0
            }
            .link(to: .easeInOut(for: 0.3) {
              selectedTribune = nil
              zoomAnchor = .center
              offset = .zero
            }, reverse: false)
        }
      }
    }
  }

  private func findAndSelectTribune(at point: CGPoint, with proxy: GeometryProxy) {
    let tribune = tribunes.flatMap { $0.1 }.first { $0.path.boundingRect.contains(point) }
    let unselected = tribune == selectedTribune
    let anchor = UnitPoint(
      x: point.x / proxy.size.width,
      y: point.y / proxy.size.height
    )

    seatsPercentage = selectedTribune == nil || !unselected ? 0.0 : 1.0

    LinkedAnimation
      .easeInOut(for: 0.7) {
        zoom = unselected ? 1.25 : 25
        seatsPercentage = unselected ? 0.0 : 1.0
        zoomed = !unselected
      }
      .link(to: .easeInOut(for: 0.3) {
        selectedTribune = unselected ? nil : tribune
        zoomAnchor = unselected ? .center : anchor
        offset = .zero
      }, reverse: !unselected)
  }

  private func findAndSelectSeat(at point: CGPoint, in selectedTribune: Tribune) {
    let seat = selectedTribune.seats.first { $0.path.boundingRect.contains(point) }
    guard let seat = seat else {
      return
    }
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
