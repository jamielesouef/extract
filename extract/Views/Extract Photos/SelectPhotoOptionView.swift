//
//  SelectPhotoOptionView.swift
//  extract
//
//  Created by Jamie Le Souef on 10/9/2025.
//

import SwiftUI

struct SelectPhotoOptionView: View {
  let option: SelectOption

  @State private var isPressed = false

  @Environment(MediaStore.self) private var store

  private let duration: TimeInterval = 0.2
  var body: some View {
    Button(action: {
      updateStore()
      withAnimation(.spring(response: duration, dampingFraction: 0.1)) {
        isPressed = true
      }

      DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
        isPressed = false
      }
    }) {
      Image(systemName: option.icon)
        .font(.system(size: Constants.SelectOption.fontSize))
        .frame(width: Constants.SelectOption.size,
               height: Constants.SelectOption.size)
        .padding(Constants.SelectOption.padding)
        .scaleEffect(isPressed ? 1.2 : 1.0)
    }
    .buttonStyle(.plain)
  }

  private func updateStore() {
    switch option {
    case .selectAll:
      store.selectAll()
    case .selectNone:
      store.selectNone()
    }
  }
}

#Preview {
  VStack {
    ForEach(SelectOption.allCases) {
      SelectPhotoOptionView(option: $0)
    }
  }
}
