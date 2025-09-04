//
//  FailedPhotosAccessView.swift
//  extract
//
//  Created by Jamie Le Souef on 26/8/2025.
//

import Foundation
import SwiftUI

struct FailedPhotosAccessView: View {
  var body: some View {
    VStack {
      Text("""
      **Well what did you expect?** You can't see anything here becuase you didn't give me access to your photos!. \
      Now you have to go into settings and give me access to your photo library.

       Don't worry. I'll wait.


       For a while....
      """)
      .multilineTextAlignment(.center)

      Button("Enable Photo Access") {
        #if os(iOS)
          if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
          }
        #elseif os(macOS)
          if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Photos") {
            NSWorkspace.shared.open(url)
          }
        #endif
      }
      .padding(.top, 20)
      .buttonStyle(.borderedProminent)
    }
  }
}

#Preview {
  FailedPhotosAccessView()
}
