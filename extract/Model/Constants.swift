//
//  Constants.swift
//  extract
//
//  Created by Jamie Le Souef on 10/9/2025.
//

import SwiftUI

enum Constants {
  enum Image {
    static let size: CGFloat = 100
    static let cornerRadius: CGFloat = 8
    static let padding: CGFloat = 16
    static let spacing: CGFloat = 8
    static let backgroundColor: Color = .secondary
    static let maxItemsForMinSpace: CGFloat = 3
    static let idealImageSize: CGFloat = 100
  }

  enum Glass {
    static let spacing: CGFloat = 8
  }

  enum SelectOption {
    static let size: CGFloat = 32
    static let fontSize: CGFloat = 24
    static let padding: CGFloat = 8
  }
}

extension CGSize {
  static var square: Self {
    Self(width: Constants.Image.cornerRadius,
         height: Constants.Image.cornerRadius)
  }
}
