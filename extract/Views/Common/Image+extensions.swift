//
//  Image+extensions.swift
//  extract
//
//  Created by Jamie Le Souef on 11/9/2025.
//

import SwiftUI

extension Image {
  init(unsafePlatformAgnosticImage image: Any?) {
    #if os(macOS)
      if let _image = image, let nsImage = _image as? NSImage {
        self.init(nsImage: nsImage)
        return
      }
    #elseif os(iOS)
      if let _image = image, let uiImage = _image as? UIImage {
        self.init(uiImage: uiImage)
        return
      }
    #endif

    //    fatalError("Image is of an unsupported platform type")
    self.init(decorative: "placeholder")
  }
}
