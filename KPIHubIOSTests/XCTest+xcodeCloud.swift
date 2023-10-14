//
//  XCTest+xcodeCloud.swift
//  KPIHubIOSTests
//
//  Created by Denys Danyliuk on 14.10.2023.
//

import SnapshotTesting
import SwiftUI
import XCTest

// https://davidbrunow.github.io/brunow.org/documentation/brunow/08-30-snapshot-testing-with-xcode-cloud/
extension XCTest {
    // https://github.com/pointfreeco/swift-snapshot-testing/discussions/553#discussioncomment-3807207
    static var xcodeCloudFilePath: StaticString {
        "/Volumes/workspace/repository/ci_scripts/SnapshotTests.swift"
    }
    static var isCIEnvironment: Bool {
        ProcessInfo.processInfo.environment["CI"] == "TRUE"
    }
    
    
//    /// Creates snapshots in a variety of different environments at the screen size of an iPhone 13 Pro (by default).
//    /// This method must be called when running tests on a device or simulator with the proper display scale
//    /// and OS version.
//    ///
//    /// Environments used for these snapshots:
//    /// * Light Mode
//    /// * Dark Mode
//    /// * All Dynamic Type Sizes
//    ///
//    /// - Parameters:
//    ///   - view: The SwiftUI `View` to snapshot.
//    ///   - snapshotDeviceOSVersions: A dictionary of the OS versions used for snapshots. Defaults
//    ///   to: ["iOS": 17.0, "macOS": 14.0, "tvOS": 17.0, "visionOS": 1.0, "watchOS": 10.0]. The test will fail
//    ///   if snapshots are recorded with a different version.
//    ///   - snapshotDeviceScale: The device scale used when recorded snapshots. Defaults to 3.0.
//    ///   The test will fail if snapshots are recorded with a different scale.
//    ///   - viewImageConfig: The `ViewImageConfig` for the snapshot. Defaults to `.iPhone13Pro`.
//    ///   - xcodeCloudFilePath: A `StaticString` describing the path that will be used when
//    ///   running these tests on Xcode Cloud. Defaults to `"/Volumes/workspace/repository/ci_scripts/SnapshotTests.swift"`. If your
//    ///   tests are in a Swift file with a name other than "SnapshotTests.swift" you will need to provide this
//    ///   same `StaticString` but with your test file's name in place of "SnapshotTests.swift".
//    ///   - file: The file in which failure occurred. Defaults to the file name of the test case in which this function was called.
//    ///   - testName: The name of the test in which failure occurred. Defaults to the function name of the test case in which this function was called.
//    ///   - line: The line number on which failure occurred. Defaults to the line number on which this function was called.
//    func assertStandardSnapshots(
//        view: some View,
//        snapshotDeviceOSVersions: [String: Double] = [
//            "iOS": 17.0,
//            "macOS": 14.0,
//            "tvOS": 17.0,
//            "visionOS": 1.0,
//            "watchOS": 10.0
//        ],
//        snapshotDeviceScale: CGFloat = 3,
//        viewImageConfig: ViewImageConfig = .iPhone13Pro,
//        xcodeCloudFilePath: StaticString = xcodeCloudFilePath,
//        file: StaticString = #file,
//        testName: String = #function,
//        line: UInt = #line
//    ) {
//        guard UIScreen.main.scale == snapshotDeviceScale else {
//            XCTFail(
//                "Running in simulator with @\(UIScreen.main.scale)x scale instead of the required @\(snapshotDeviceScale)x scale.",
//                file: file,
//                line: line
//            )
//            return
//        }
//        let snapshotDeviceOSVersion: String
//#if os(iOS)
//        guard let version = snapshotDeviceOSVersions["iOS"] else {
//            XCTFail(
//                "iOS version not provided.",
//                file: file,
//                line: line
//            )
//            return
//        }
//        snapshotDeviceOSVersion = "\(version)"
//#elseif os(macOS)
//        guard let version = snapshotDeviceOSVersions["macOS"] else {
//            XCTFail(
//                "macOS version not provided.",
//                file: file,
//                line: line
//            )
//            return
//        }
//        snapshotDeviceOSVersion = "\(version)"
//#elseif os(tvOS)
//        guard let version = snapshotDeviceOSVersions["tvOS"] else {
//            XCTFail(
//                "tvOS version not provided.",
//                file: file,
//                line: line
//            )
//            return
//        }
//        snapshotDeviceOSVersion = "\(version)"
//#elseif os(visionOS)
//        guard let version = snapshotDeviceOSVersions["visionOS"] else {
//            XCTFail(
//                "visionOS version not provided.",
//                file: file,
//                line: line
//            )
//            return
//        }
//        snapshotDeviceOSVersion = "\(version)"
//#elseif os(watchOS)
//        guard let version = snapshotDeviceOSVersions["watchOS"] else {
//            XCTFail(
//                "watchOS version not provided.",
//                file: file,
//                line: line
//            )
//            return
//        }
//        snapshotDeviceOSVersion = "\(version)"
//#endif
//        guard UIDevice.current.systemVersion == "\(snapshotDeviceOSVersion)" else {
//            XCTFail(
//                "Running with OS version \(UIDevice.current.systemVersion) instead of the required OS version \(snapshotDeviceOSVersion).",
//                file: file,
//                line: line
//            )
//            return
//        }
//        
//        
//        let filePath: StaticString
//        
//        
//        if Self.isCIEnvironment {
//            filePath = xcodeCloudFilePath
//        } else {
//            filePath = file
//        }
//        
//        
//        for colorScheme in ColorScheme.allCases {
//            let viewController = UIHostingController(
//                rootView: view
//                    .transaction {
//                        $0.disablesAnimations = true
//                    }
//                    .background(colorScheme == .light ? Color.white : Color.black)
//                    .environment(\.colorScheme, colorScheme)
//            )
//            viewController.view.backgroundColor = colorScheme == .light ? .white : .black
//            
//            
//            assertSnapshot(
//                matching: viewController,
//                as: .image(on: viewImageConfig),
//                named: "\(name) - Color Scheme: \(colorScheme)",
//                file: filePath,
//                testName: testName,
//                line: line
//            )
//        }
//        
//        
//        for size in DynamicTypeSize.allCases {
//            let viewController = UIHostingController(
//                rootView: view
//                    .transaction {
//                        $0.disablesAnimations = true
//                    }
//                    .environment(\.dynamicTypeSize, size)
//            )
//            
//            
//            assertSnapshot(
//                matching: viewController,
//                as: .image(on: viewImageConfig),
//                named: "\(name) - Dynamic Type: \(size)",
//                file: filePath,
//                testName: testName,
//                line: line
//            )
//        }
//    }
}

//import Foundation
//import SnapshotTesting
//import XCTest
//
///// Returns a valid snapshot directory under the project’s `ci_scripts`.
/////
///// - Parameter file: A `StaticString` representing the current test’s filename.
///// - Returns: A directory for the snapshots.
///// - Note: It makes strong assumptions about the structure of the project; namely,
/////   it expects the project to consist of a single package located at the root.
//func snapshotDirectory(
//    for file: StaticString,
//    testsPathComponent: String = "Tests",
//    ciScriptsPathComponent: String = "ci_scripts",
//    snapshotsPathComponent: String = "__Snapshots__"
//) -> String {
//    let fileURL = URL(fileURLWithPath: "\(file)", isDirectory: false)
//
//    let packageRootPath = fileURL
//        .pathComponents
//        .prefix(while: { $0 != testsPathComponent })
//
//    let testsPath = packageRootPath + [testsPathComponent]
//
//    let relativePath = fileURL
//        .deletingPathExtension()
//        .pathComponents
//        .dropFirst(testsPath.count)
//
//    let snapshotDirectoryPath = packageRootPath + [ciScriptsPathComponent, snapshotsPathComponent] +
//        relativePath
//    return snapshotDirectoryPath.joined(separator: "/")
//}
//
///// Asserts that a given value matches references on disk.
/////
///// - Parameters:
/////   - value: A value to compare against a reference.
/////   - snapshotting: An array of strategies for serializing, deserializing, and comparing values.
/////   - recording: Whether or not to record a new reference.
/////   - timeout: The amount of time a snapshot must be generated in.
/////   - file: The file in which failure occurred. Defaults to the file name of the test case in which this function was called.
/////   - testName: The name of the test in which failure occurred. Defaults to the function name of the test case in which this function was called.
/////   - line: The line number on which failure occurred. Defaults to the line number on which this function was called.
/////   - testsPathComponent: The name of the tests directory. Defaults to “Tests”.
//public func ciAssertSnapshot<Value, Format>(
//    matching value: @autoclosure () throws -> Value,
//    as snapshotting: Snapshotting<Value, Format>,
//    named name: String? = nil,
//    record recording: Bool = false,
//    timeout: TimeInterval = 5,
//    file: StaticString = #file,
//    testName: String = #function,
//    line: UInt = #line,
//    testsPathComponent: String = "Tests"
//) {
////    verifySnapshot(of: <#T##Value#>, as: <#T##Snapshotting<Value, Format>#>)
//    let failure = verifySnapshot(
//        matching: try value(),
//        as: snapshotting,
//        named: name,
//        record: recording,
//        snapshotDirectory: snapshotDirectory(for: file, testsPathComponent: testsPathComponent),
//        timeout: timeout,
//        file: file,
//        testName: testName
//    )
//
//    guard let message = failure else { return }
//    XCTFail(message, file: file, line: line)
//}
