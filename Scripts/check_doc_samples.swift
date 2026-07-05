#!/usr/bin/env swift

// Compile-checks Swift code samples embedded in this repo's Markdown docs
// against the real ThemeKit public API, so README/DocC/skill examples can't
// silently drift from the actual source (renamed types, changed signatures,
// removed protocol requirements, etc.).
//
// Only code fences explicitly opted in via a marker comment are checked:
//
//     <!-- doc-check: <group-name> platform=<macos|ios> -->
//     ```swift
//     ...
//     ```
//
// Blocks sharing the same <group-name> are concatenated in document order
// into a single file before type-checking, so a multi-step example (struct ->
// variant -> accessor -> app) can span several fences. Each group is compiled
// as its own SwiftPM target in a throwaway harness package, so identical type
// names reused across unrelated groups (e.g. two different `AppColors`
// definitions) never collide.
//
// This is NOT a general doc-test framework: it does no text substitution,
// stub injection, or partial-line extraction. A group must be genuinely
// self-contained as literally written (no undefined helper types, no bare
// top-level statements, no "(...)" elisions) to be markable. Most
// narrative/usage snippets in the docs are intentionally partial and are left
// unmarked -- that's expected, not a gap in this script.
//
// Usage: Scripts/check_doc_samples.swift (or `swift Scripts/check_doc_samples.swift`)

import Foundation

let repoRoot = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()  // Scripts/
    .deletingLastPathComponent()  // repo root

let markdownFiles = [
    "README.md",
    "Sources/ThemeKit/ThemeKit.docc/ThemeKit.md",
    "Sources/ThemeKitSwiftUI/ThemeKitSwiftUI.docc/ThemeKitSwiftUI.md",
    "Sources/ThemeKitUIKit/ThemeKitUIKit.docc/ThemeKitUIKit.md",
    ".agents/skills/themekit/SKILL.md",
]

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(("Error: " + message + "\n").data(using: .utf8)!)
    exit(1)
}

struct Block {
    let file: String
    let line: Int
    let code: String
}

struct Group {
    var platform: String
    var blocks: [Block] = []
}

let markerPattern =
    #"<!--\s*doc-check:\s*(?<group>[\w.-]+)\s+platform=(?<platform>ios|macos)\s*-->\n```swift\n(?<code>.*?)\n```"#

guard
    let markerRegex = try? NSRegularExpression(
        pattern: markerPattern, options: [.dotMatchesLineSeparators])
else {
    fail("invalid marker regex")
}

let importRegex = try! NSRegularExpression(
    pattern: #"^\s*import\s+(ThemeKit(?:SwiftUI|UIKit)?)\s*$"#, options: [.anchorsMatchLines])

var groups: [String: Group] = [:]

for relPath in markdownFiles {
    let fileURL = repoRoot.appendingPathComponent(relPath)
    guard let text = try? String(contentsOf: fileURL, encoding: .utf8) else {
        fail("could not read \(relPath)")
    }
    let nsText = text as NSString
    let fullRange = NSRange(location: 0, length: nsText.length)

    markerRegex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
        guard let match else { return }
        let groupRange = match.range(withName: "group")
        let platformRange = match.range(withName: "platform")
        let codeRange = match.range(withName: "code")
        guard groupRange.location != NSNotFound, platformRange.location != NSNotFound,
            codeRange.location != NSNotFound
        else { return }

        let name = nsText.substring(with: groupRange)
        let platform = nsText.substring(with: platformRange)
        let code = nsText.substring(with: codeRange)

        let prefix = nsText.substring(to: match.range.location)
        let lineNumber = prefix.reduce(1) { $1 == "\n" ? $0 + 1 : $0 }

        if groups[name] == nil {
            groups[name] = Group(platform: platform)
        }
        if groups[name]!.platform != platform {
            fail(
                "\(relPath):\(lineNumber): doc-check group '\(name)' declared as "
                    + "platform=\(platform) but was already platform=\(groups[name]!.platform)")
        }
        groups[name]!.blocks.append(Block(file: relPath, line: lineNumber, code: code))
    }
}

if groups.isEmpty {
    print("No doc-check groups found.")
    exit(0)
}

let harnessRoot = repoRoot.appendingPathComponent(".build/doc-samples-check")
try? FileManager.default.removeItem(at: harnessRoot)

func detectProducts(in code: String) -> Set<String> {
    var products: Set<String> = ["ThemeKit"]
    let nsCode = code as NSString
    let matches = importRegex.matches(
        in: code, options: [], range: NSRange(location: 0, length: nsCode.length))
    for match in matches {
        products.insert(nsCode.substring(with: match.range(at: 1)))
    }
    return products
}

/// Writes a throwaway SwiftPM package containing one target per group, and
/// returns its directory, or `nil` if there are no groups for this platform.
func writeHarness(platform: String, groupNames: [String]) throws -> URL? {
    guard !groupNames.isEmpty else { return nil }
    let dir = harnessRoot.appendingPathComponent(platform)
    let sourcesDir = dir.appendingPathComponent("Sources")
    try FileManager.default.createDirectory(at: sourcesDir, withIntermediateDirectories: true)

    var targets: [String] = []
    for name in groupNames.sorted() {
        let group = groups[name]!
        let code = group.blocks.map(\.code).joined(separator: "\n\n")
        let products = detectProducts(in: code)

        var preamble = ["import Foundation"]
        preamble.append(platform == "macos" ? "import SwiftUI" : "import UIKit")
        preamble.append(contentsOf: products.sorted().map { "import \($0)" })

        let targetDir = sourcesDir.appendingPathComponent(name)
        try FileManager.default.createDirectory(at: targetDir, withIntermediateDirectories: true)
        let fileContents = preamble.joined(separator: "\n") + "\n\n" + code + "\n"
        try fileContents.write(
            to: targetDir.appendingPathComponent("Sample.swift"), atomically: true,
            encoding: .utf8)

        let deps = products.sorted().map { #".product(name: "\#($0)", package: "ThemeKit")"# }
            .joined(separator: ", ")
        targets.append(
            "        .target(name: \"\(name)\", dependencies: [\(deps)], path: \"Sources/\(name)\")"
        )
    }

    let packageSwift = """
        // swift-tools-version: 6.0
        import PackageDescription

        let package = Package(
            name: "DocSamplesCheck",
            platforms: [.iOS(.v17), .macOS(.v14)],
            dependencies: [.package(path: "\(repoRoot.path)")],
            targets: [
        \(targets.joined(separator: ",\n"))
            ]
        )
        """
    try packageSwift.write(
        to: dir.appendingPathComponent("Package.swift"), atomically: true, encoding: .utf8)
    return dir
}

@discardableResult
func run(_ executable: String, _ arguments: [String]) -> (status: Int32, output: String) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: executable)
    process.arguments = arguments
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe
    try? process.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    return (process.terminationStatus, String(data: data, encoding: .utf8) ?? "")
}

func build(packageDir: URL, extraArgs: [String], label: String) -> Bool {
    print("--- building \(label) ---")
    let args = ["build", "--package-path", packageDir.path] + extraArgs
    let (status, output) = run("/usr/bin/env", ["swift"] + args)
    print(output)
    return status == 0
}

let macosGroups = groups.filter { $0.value.platform == "macos" }.map(\.key)
let iosGroups = groups.filter { $0.value.platform == "ios" }.map(\.key)

var ok = true

if let macosDir = try? writeHarness(platform: "macos", groupNames: macosGroups) {
    ok = build(packageDir: macosDir, extraArgs: [], label: "macOS groups") && ok
}

if let iosDir = try? writeHarness(platform: "ios", groupNames: iosGroups) {
    let (sdkStatus, sdkOutput) = run(
        "/usr/bin/env", ["xcrun", "--sdk", "iphonesimulator", "--show-sdk-path"])
    guard sdkStatus == 0 else { fail("could not resolve iphonesimulator SDK path") }
    let sdkPath = sdkOutput.trimmingCharacters(in: .whitespacesAndNewlines)
    ok =
        build(
            packageDir: iosDir,
            extraArgs: ["--sdk", sdkPath, "--triple", "arm64-apple-ios17.0-simulator"],
            label: "iOS groups") && ok
}

if !ok {
    print("\ndoc sample check FAILED -- a Markdown code sample no longer matches the public API.")
    for (name, group) in groups.sorted(by: { $0.key < $1.key }) {
        let locations = group.blocks.map { "\($0.file):\($0.line)" }.joined(separator: ", ")
        print("  \(name) (\(group.platform)): \(locations)")
    }
    exit(1)
}

print("\ndoc sample check passed -- \(groups.count) group(s) compiled.")
