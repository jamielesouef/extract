//
//  slog.swift
//  extract
//
//  Created by Jamie Le Souef on 29/8/2025.
//


import Foundation

@inlinable
public func slog(
  _ parts: Any...,
  fileID: StaticString = #fileID,
  line: Int = #line,
  function: StaticString = #function
) {
#if DEBUG
  let message = parts.map { String(describing: $0) }.joined(separator: " | ")
  debugPrint("---| \(fileID)::\(function):\(line) --: \(message)")
#endif
}
