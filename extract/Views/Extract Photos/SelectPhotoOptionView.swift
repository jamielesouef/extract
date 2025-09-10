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

  private let duration: TimeInterval = 0.2
  var body: some View {
    Button(action: {
      withAnimation(.spring(response: self.duration, dampingFraction: 0.1)) {
        self.isPressed = true
      }

      DispatchQueue.main.asyncAfter(deadline: .now() + self.duration) {
        self.isPressed = false
      }
    }) {
      Image(systemName: self.option.icon)
        .font(.system(size: Constants.SelectOption.fontSize))
        .frame(
          width: Constants.SelectOption.size,
          height: Constants.SelectOption.size
        )
        .padding(Constants.SelectOption.padding)
        .scaleEffect(self.isPressed ? 1.2 : 1.0)
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  VStack {
    ForEach(SelectOption.allCases) {
      SelectPhotoOptionView(option: $0)
    }
  }
}
