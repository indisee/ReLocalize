#!/usr/bin/env xcrun swift

import Cocoa

print("Start")

var localizationPath:String = ""
var sourceDirectory:String = ""
var fileToWriteTo:String = ""

var prevFlagName:String? = nil
for (idx, arg) in CommandLine.arguments.enumerated() {
    if idx == 0 {
        continue
    }
    if let prevFlagName = prevFlagName {
        switch prevFlagName {
        case "-l":
            localizationPath = arg
        case "-s":
            sourceDirectory = arg
        case "-f":
            fileToWriteTo = arg
        default:
            break;
        }
    }
    prevFlagName = nil
    if ["-l","-s","-f"].contains(arg) {
        prevFlagName = arg
    }
}

print("localizationPath \(localizationPath)")
print("sourceDirectory \(sourceDirectory)")
print("fileToWriteEnumTo \(fileToWriteTo)")
print("------------")

let localization = reMapLocalizedToDict(path: localizationPath)
var enumStr = generateEnumCasesString(from: localization)
saveEnumCasesString(enumStr, to: fileToWriteTo)
print("localization count \(localization.count)\n----")
replaceStringByEnum(sourceDirectory:sourceDirectory, localization:localization)
print("done")


func replaceStringByEnum(sourceDirectory:String, localization:[String:String]) {
    let url = URL(fileURLWithPath: sourceDirectory)
    if let enumerator = FileManager.default.enumerator(at: url,
                                                       includingPropertiesForKeys: [.isRegularFileKey],
                                                       options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
        for case let fileURL as URL in enumerator {
            do {
                if fileURL.pathExtension == "swift" {
                    
                    let text = try String(contentsOf: fileURL, encoding: .utf8)
                    var newText = text
                    for (k, _) in localization {
                        newText = newText.replacingOccurrences(of: "\(k).localized", with: "S.\(generateEnumKey(from: k)).localizedString")
                    }
                    
                    if text != newText {
                        print("change file \(fileURL.lastPathComponent)")
                        try newText.write(to: URL(fileURLWithPath: fileURL.path),
                                       atomically: false,
                                       encoding: .utf8)
                    }
                }
                
            } catch { print(error, fileURL) }
        }
    }
}

func reMapLocalizedToDict(path:String) -> [String:String] {
    var localization = [String:String]()
    if let localizationStringsData = FileManager.default.contents(atPath: path),
       let localizationStrings = NSString(data: localizationStringsData, encoding: String.Encoding.utf8.rawValue) as? String
    {
        localization = localizationStrings.components(separatedBy: ";\n").filter {
            !$0.isEmpty
        }.reduce([String:String]()) {
            let keyVal = $1.components(separatedBy: " = ")
            let key = keyVal[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let val = keyVal[1]
            return $0.merging([key:val]) {
                $1
            }
        }
    }
    return localization
}

func generateEnumCasesString(from localization: [String:String]) -> String {
    var enumStr = ""
    for (k, _) in localization {
        let line = "case \(generateEnumKey(from: k)) = \(k)\n"
        enumStr.append(contentsOf: line)
    }
    return enumStr
}

func generateEnumKey(from str:String) -> String {
    let cleanStr = str.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\"", with: "")
    var final = ""
    var nextUp = false
    for c in cleanStr {
        if c == "." {
            nextUp = true
        } else {
            final.append(contentsOf: (nextUp ? String(c).uppercased() : String(c)))
            nextUp = false
        }
    }
    return final
}

func saveEnumCasesString(_ enumStr:String, to fileToWriteTo:String) {
    do {
        try enumStr.write(to: URL(fileURLWithPath: fileToWriteTo),
                          atomically: false,
                          encoding: .utf8)
    }
    catch {
        print(error)
    }
}
