//
//  SelectPhotoView.swift
//  extract
//
//  Created by Jamie Le Souef on 10/9/2025.
//

import SwiftUI

enum SelectOption: String, Identifiable {
  case selectAll
  case selectNone

  var id: String {
    return self.rawValue
  }

  var icon: String {
    switch self {
    case .selectAll:
      return "checkmark.circle"
    case .selectNone:
      return "circle"
    }
  }

  static var allCases: [Self] {
    return [.selectAll, .selectNone]
  }
}

struct SelectPhotoView: View {
  @State private var isShowingImagePicker: Bool = false
  @Namespace private var namespace

  var body: some View {
    GlassEffectContainer(spacing: Constants.Glass.spacing) {
      VStack(alignment: .center) {
        if isShowingImagePicker {
          ForEach(SelectOption.allCases) { option in
            SelectPhotoOptionView(option: option)
              .glassEffect(.regular, in: .circle)
              .glassEffectID(option.id, in: namespace)
          }
        }
        Button(action: {
          withAnimation {
            isShowingImagePicker.toggle()
          }
        }) {
          Image(
            systemName: isShowingImagePicker
              ? "checklist" : "checklist.unchecked"
          )
          .frame(
            width: Constants.SelectOption.size,
            height: Constants.SelectOption.size
          )
        }
      
        .buttonStyle(.glass)
        .glassEffectID("selectToggleButton", in: namespace)
      }
    }
  }
}

#Preview {
  SelectPhotoView()
}
