//
//  ForDevelopersTests.swift
//  KPIHubIOSTests
//
//  Created by Denys Danyliuk on 14.10.2023.
//

import XCTest
import ComposableArchitecture
import SnapshotTesting
import SwiftUI
@testable import KPIHubIOS

class ForDevelopersTests: XCTestCase {
    func testScreen() {
        let store = StoreOf<ForDevelopers>(
            initialState: ForDevelopers.State(),
            reducer: {
                ForDevelopers()
            },
            withDependencies: {
                $0.analyticsService = .none()
            }
        )
        let locales = [Locale(identifier: "en-US"), Locale(identifier: "uk-UA")]
        let configs = [ViewImageConfig.iPhone8, ViewImageConfig.iPhone13, ViewImageConfig.iPhone13ProMax]
        
        createPairs(configs, locales).forEach { config, locale in
            let profileView = NavigationStack {
                ForDevelopersView(store: store)
            }
            .environment(\.locale, locale)
//            assertSnapshot(
//                of: profileView,
//                as: .image(perceptualPrecision: 0.99, layout: .device(config: config)),
//                named: "\(config.description)-\(locale.identifier)",
//                record: false
//            )
//            let some =
            myAssertSnapshot(
                of: profileView,
                as: .image(perceptualPrecision: 0.99, layout: .device(config: config)),
                named: "\(config.description)-\(locale.identifier)",
                bundleURL: Bundle(for: type(of: self)).resourceURL!
            )
        }
    }
}

public func myAssertSnapshot<Value, Format>(
    of value: @autoclosure () throws -> Value,
    as snapshotting: Snapshotting<Value, Format>,
    named name: String? = nil,
    record recording: Bool = false,
    timeout: TimeInterval = 5,
    file: StaticString = #file,
    testName: String = #function,
    line: UInt = #line,
    bundleURL: URL
) {
    
    let testClassFileURL = URL(fileURLWithPath: "\(file)", isDirectory: false)
    let testClassName = testClassFileURL.deletingPathExtension().lastPathComponent

    print("!!! bundleURL: \(bundleURL)")

    let folderCandidates = [
        // For SPM modules.
        bundleURL.appending(path: "__Snapshots__").appending(path: testClassName),
        // For top-level xcodeproj app target.
        bundleURL//.appending(path: testClassName)
    ]
    
    var snapshotDirectory: String? = nil
    
    for folder in folderCandidates {
        let prefix = testName.dropLast(2)
        let referenceSnapshotURLInTestBundle = folder.appending(path: "\(prefix).\(name ?? "").png")
        print("!!! referenceSnapshotURLInTestBundle: \(referenceSnapshotURLInTestBundle)")
        if FileManager.default.fileExists(atPath: referenceSnapshotURLInTestBundle.path(percentEncoded: false)) {
            // The snapshot file is present in the test bundle, so we will instruct snapshot-testing to use the folder
            // pointing to the snapshots in the test bundle, instead of the default.
            // This is the code path that Xcode Cloud will follow, if everything is set up correctly.
            snapshotDirectory = folder.path(percentEncoded: false)
        }
    }

    print("!!! snapshot dir: \(snapshotDirectory)")
    let failure = verifySnapshot(
        of: try value(),
        as: snapshotting,
        named: name,
        record: recording,
        snapshotDirectory: snapshotDirectory,
        timeout: timeout,
        file: file,
        testName: testName,
        line: line
    )
    guard let message = failure else { return }
    XCTFail(message, file: file, line: line)
}
