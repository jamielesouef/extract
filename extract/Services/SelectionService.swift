//
//  SelectionService.swift
//  extract
//
//  Created by Jamie Le Souef on 10/9/2025.
//

protocol SelectionServicing {
  func select(_ asset: String)
  func deselect(_ asset: String)
}

final class SelectionService: SelectionServicing {
  private var selected: Set<String> = []

  func select(_ asset: String) {
    self.selected.insert(asset)
  }

  func deselect(_ asset: String) {
    self.selected.remove(asset)
  }
}
