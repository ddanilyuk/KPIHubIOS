//
//  SnapshotHelpers.swift
//  KPIHubIOSTests
//
//  Created by Denys Danyliuk on 14.10.2023.
//

import Foundation
import SnapshotTesting
import XCTest
import SwiftUI

public func assertAllSnapshots<Value: View>(
    of value: @escaping () -> Value,
    file: StaticString = #file,
    testName: String = #function,
    line: UInt = #line
) {
    isRecording = false
    let locales = [Locale(identifier: "en-US"), Locale(identifier: "uk-UA")]
    let configs = [ViewImageConfig.iPhone8, ViewImageConfig.iPhone13, ViewImageConfig.iPhone13ProMax]
    
    createPairs(configs, locales).forEach { config, locale in
        myAssertSnapshot(
            of: value().environment(\.locale, locale),
            as: .image(perceptualPrecision: 0.99, layout: .device(config: config)),
            named: "\(config.description)-\(locale.identifier)",
            file: file,
            testName: testName,
            line: line
        )
    }
}

public func myAssertSnapshot<Value: View, Format>(
    of value: Value,
    as snapshotting: Snapshotting<Value, Format>,
    named name: String? = nil,
    record recording: Bool = false,
    timeout: TimeInterval = 5,
    file: StaticString = #file,
    testName: String = #function,
    line: UInt = #line
) {
    let testClassFileURL = URL(fileURLWithPath: "\(file)", isDirectory: false)
    let testClassName = testClassFileURL.deletingPathExtension().lastPathComponent
    let folder = Bundle.current.resourceURL!.appending(path: "__Snapshots__").appending(path: testClassName)
    let failure = verifySnapshot(
        of: value,
        as: snapshotting,
        named: name,
        record: recording,
        snapshotDirectory: folder.path(percentEncoded: false),
        timeout: timeout,
        file: file,
        testName: testName,
        line: line
    )
    guard let message = failure else { return }
    XCTFail(message, file: file, line: line)
}

private func sanitizePathComponent(_ string: String) -> String {
    string
        .replacingOccurrences(of: "\\W+", with: "-", options: .regularExpression)
        .replacingOccurrences(of: "^-|-$", with: "", options: .regularExpression)
}

private extension Bundle {
    private class EmptyClass {}
    static let current = Bundle(for: EmptyClass.self)
}

extension ViewImageConfig {
    var description: String {
        switch self.size {
        case ViewImageConfig.iPhone8.size:
            return "iPhone8"
        case ViewImageConfig.iPhone13.size:
            return "iPhone13"
        case ViewImageConfig.iPhone13ProMax.size:
            return "iPhone13ProMax"
        default:
            return "no info"
        }
    }
}

func createPairs<T, U>(_ array1: [T], _ array2: [U]) -> [(T, U)] {
    var pairs: [(T, U)] = []
    
    for item1 in array1 {
        for item2 in array2 {
            pairs.append((item1, item2))
        }
    }
    
    return pairs
}
