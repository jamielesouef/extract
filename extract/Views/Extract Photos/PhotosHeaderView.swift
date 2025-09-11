//
//  PhotosHeaderView.swift
//  extract
//
//  Created by Jamie Le Souef on 2/9/2025.
//

import SwiftUI

struct PhotosHeaderView: View {
  let count: Int
  let photosCount: Int
  let videoCount: Int
  let image: String

  private let textOpacity: CGFloat = 0.8
  var body: some View {
    Image(decorative: image)
      .resizable()
      .aspectRatio(contentMode: .fill)
      .frame(minWidth: 0,
             maxWidth: .infinity,
             minHeight: 0,
             maxHeight: .infinity)
      .clipped()
    #if os(iOS)
      .backgroundExtensionEffect()
    #endif
      .overlay(alignment: .bottom) {
        VStack {
          Text("Media")
            .font(.subheadline)
            .fontWeight(.bold)
            .foregroundStyle(.white)
            .opacity(textOpacity)

          Text(
            "\(photosCount.formatted()) photos, \(videoCount.formatted()) videos"
          )
          .font(.largeTitle)
          .fontWeight(.bold)
          .foregroundStyle(.white)
          .lineLimit(1)
          .minimumScaleFactor(0.5)
          .allowsTightening(true)
          .frame(maxWidth: .infinity, alignment: .center)
          .padding([.leading, .trailing])

          Button(action: {}) {
            Text("Backup now")
          }
          #if os(iOS)
          .glassEffect()
          #endif
          .buttonStyle(.borderedProminent)
          .padding([.bottom, .top], Constants.Image.padding)
        }
      }
  }
}

#Preview("Landscape Image") {
  PhotosHeaderView(count: 1234, photosCount: 1000, videoCount: 234, image: "cat-landscape")
    .frame(height: 440)
}

#Preview("Portrate Image") {
  PhotosHeaderView(count: 1234, photosCount: 1000, videoCount: 234, image: "cat-portrait")
    .frame(height: 440)
}
