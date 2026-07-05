#!/usr/bin/env swift

// Fails if CHANGELOG.md has no "## [<tag>]" entry for the given tag -- catches
// a tag shipped with no changelog section at all (a real gap: 0.2.2 shipped
// with no entry until this was caught by hand).
//
// Also does a soft, non-fatal check: do the inline-code symbols mentioned in
// that entry actually appear somewhere in the tag's diff? This is intentionally
// a warning, not a failure -- unlike Scripts/check_doc_samples.swift, there's
// no way to compile prose, and a symbol can legitimately be described without
// being part of the diff (e.g. referencing an unrelated existing API).
//
// Usage: Scripts/check_changelog_entry.swift [<tag>]
//   <tag> defaults to the most recent tag reachable from HEAD.

import Foundation

let repoRoot = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()  // Scripts/
    .deletingLastPathComponent()  // repo root

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(("Error: " + message + "\n").data(using: .utf8)!)
    exit(1)
}

@discardableResult
func run(_ arguments: [String]) -> (status: Int32, output: String) {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = arguments
    process.currentDirectoryURL = repoRoot
    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe
    try? process.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    return (process.terminationStatus, String(data: data, encoding: .utf8) ?? "")
}

func git(_ arguments: String...) -> String? {
    let (status, output) = run(["git", "-C", repoRoot.path] + arguments)
    guard status == 0 else { return nil }
    return output.trimmingCharacters(in: .whitespacesAndNewlines)
}

let tag = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : (git("describe", "--tags", "--abbrev=0") ?? "")
guard !tag.isEmpty else { fail("could not resolve a tag (none given, and no tags reachable from HEAD)") }

print("Checking CHANGELOG.md for tag: \(tag)")

let changelogURL = repoRoot.appendingPathComponent("CHANGELOG.md")
guard let changelog = try? String(contentsOf: changelogURL, encoding: .utf8) else {
    fail("could not read CHANGELOG.md")
}

let escapedTag = NSRegularExpression.escapedPattern(for: tag)
let headingRegex = try! NSRegularExpression(
    pattern: "^## \\[\(escapedTag)\\]", options: [.anchorsMatchLines])
let nsChangelog = changelog as NSString
let headingRange = NSRange(location: 0, length: nsChangelog.length)
guard let headingMatch = headingRegex.firstMatch(in: changelog, options: [], range: headingRange)
else {
    fail("CHANGELOG.md has no '## [\(tag)]' entry.")
}
print("  found heading for \(tag)")

// Slice out this tag's section: from the heading to the next "## [" heading, or EOF.
let nextHeadingRegex = try! NSRegularExpression(pattern: "^## \\[", options: [.anchorsMatchLines])
let searchStart = headingMatch.range.location + headingMatch.range.length
let searchRange = NSRange(location: searchStart, length: nsChangelog.length - searchStart)
let sectionEnd =
    nextHeadingRegex.firstMatch(in: changelog, options: [], range: searchRange)?.range.location
    ?? nsChangelog.length
let section = nsChangelog.substring(
    with: NSRange(location: searchStart, length: sectionEnd - searchStart))

// Pull out backtick-delimited symbols mentioned in that section.
let symbolRegex = try! NSRegularExpression(pattern: "`([A-Za-z_][A-Za-z0-9_.<>:-]*)`")
let nsSection = section as NSString
let symbols = Set(
    symbolRegex.matches(in: section, options: [], range: NSRange(location: 0, length: nsSection.length))
        .map { nsSection.substring(with: $0.range(at: 1)) })

guard let prevTag = git("describe", "--tags", "--abbrev=0", "\(tag)^"), !symbols.isEmpty else {
    print("  (no previous tag or no inline-code symbols to cross-check)")
    print("CHANGELOG check passed for \(tag).")
    exit(0)
}

let diff = git("diff", prevTag, tag) ?? ""
let missing = symbols.filter { !diff.contains($0) }.sorted()

if !missing.isEmpty {
    print("Warning: symbols in the \(tag) changelog entry not found in 'git diff \(prevTag) \(tag)':")
    print("  " + missing.joined(separator: " "))
    print("(non-fatal -- may be legitimate prose, but worth a second look)")
}

print("CHANGELOG check passed for \(tag).")
