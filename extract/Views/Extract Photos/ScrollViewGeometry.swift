//
//  ScrollViewGeometry.swift
//  extract
//
//  Created by Jamie Le Souef on 11/9/2025.
//

import SwiftUI

@Observable private class ScrollViewGeometry {
  var offset: CGFloat = 0
}

private struct PhotosHeaderViewFlexableModifider: ViewModifier {
  @Environment(AppState.self) var appState
  @Environment(ScrollViewGeometry.self) var scrollViewGeometry

  func body(content: Content) -> some View {
    let height = (appState.windowSize.height / 2) - scrollViewGeometry.offset
    content
      .frame(height: height)
      .padding(.bottom, scrollViewGeometry.offset)
      .offset(y: scrollViewGeometry.offset)
  }
}

private struct ScrollViewGeometryReaader: ViewModifier {
  @State private var scrollViewGeometry = ScrollViewGeometry()

  func body(content: Content) -> some View {
    content
      .onScrollGeometryChange(for: CGFloat.self) { proxy in
        min(proxy.contentOffset.y + proxy.contentOffset.x, 0)
      } action: { oldValue, newValue in
        if oldValue != newValue {
          scrollViewGeometry.offset = newValue
        }
      }
      .environment(scrollViewGeometry)
  }
}

extension View {
  func photosHeaderViewFlexableModifider() -> some View {
    modifier(PhotosHeaderViewFlexableModifider())
  }
}

extension View {
  func scrollViewGeometryReader() -> some View {
    modifier(ScrollViewGeometryReaader())
  }
}
