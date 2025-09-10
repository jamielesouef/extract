//
//  SelectAllPhotosView.swift
//  extract
//
//  Created by Jamie Le Souef on 10/9/2025.
//

import SwiftUI

enum SelectOption: String, Identifiable {
  case selectAll
  case selectNone

  var id: String {
    rawValue
  }

  var icon: String {
    switch self {
    case .selectAll:
      "checkmark.circle"
    case .selectNone:
      "circle"
    }
  }

  static var allCases: [Self] {
    [.selectAll, .selectNone]
  }
}

struct SelectAllPhotosView: View {
  @Environment(MediaStore.self) var store

  @Namespace private var namespace

  var body: some View {
    @Bindable var store = store
    #if os(iOS)
      GlassEffectContainer(spacing: Constants.Glass.spacing) {
        VStack(alignment: .center) {
          if store.isInSelectMode {
            ForEach(SelectOption.allCases) { option in
              SelectPhotoOptionView(option: option)
                .glassEffect(.regular, in: .circle)
                .glassEffectID(option.id, in: self.namespace)
            }
          }
          Button(action: {
            withAnimation {
              store.isInSelectMode.toggle()
            }
          }) {
            Image(
              systemName: store.isInSelectMode
                ? "checklist" : "checklist.unchecked"
            )
            .frame(
              width: Constants.SelectOption.size,
              height: Constants.SelectOption.size
            )
          }
          .buttonStyle(.glass)
          .glassEffectID("selectToggleButton", in: self.namespace)
        }
      }
    #else
      Text("No mac")
    #endif
  }
}

private struct SelectAllPhotosViewModifiers: ViewModifier {
  func body(content: Content) -> some View {
    ZStack {
      content
      HStack {
        Spacer()
        VStack {
          Spacer()
          SelectAllPhotosView()
            .padding()
        }
      }
    }
  }
}

extension View {
  func showSelectAll() -> some View {
    modifier(SelectAllPhotosViewModifiers())
  }
}

#Preview {
  @Previewable @State var store = MediaStore()
  VStack {
    SelectAllPhotosView()
    SelectAllPhotosView()
  }
  .environment(store)
}
