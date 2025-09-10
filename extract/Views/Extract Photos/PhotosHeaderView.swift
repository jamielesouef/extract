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

  var body: some View {
    Text("total: \(self.count)")
    Text("Photos: \(self.photosCount.formatted()), Videos: \(self.videoCount.formatted())")
    Text("Media items since last backup")
  }
}

#Preview {
  PhotosHeaderView(count: 1234, photosCount: 1000, videoCount: 234)
}
