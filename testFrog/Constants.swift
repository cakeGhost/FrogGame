//
//  Constraint.swift
//  testFrog
//
//  Created by suding on 2021/12/09.
//


import Foundation

struct PhysicsCategory {
    static let frog: UInt32 = 0x1 << 0  // 1
    static let land: UInt32 = 0x1 << 1  //  2
    static let wallUp: UInt32 = 0x1 << 2 // 4
    static let wallDown: UInt32 = 0x1 << 3 // 8
    static let score: UInt32 = 0x1 << 4 // 16
}
