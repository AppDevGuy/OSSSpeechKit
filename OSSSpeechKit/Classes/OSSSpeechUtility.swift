//  Copyright © 2018-2020 App Dev Guy. All rights reserved.
//
//  This code is distributed under the terms and conditions of the MIT license.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

import UIKit

public class OSSSpeechUtility: NSObject {
    
    // MARK: - Variables
    
    fileprivate var tableName = "Localizable"
    
    /// Change this property to your strings table name if you wish to override the SDK strings values in your app.
    public var stringsTableName: String {
        get {
            return tableName
        }
        set {
            tableName = newValue
        }
    }
    
    // MARK: - Public Methods
    
    /// A helper method that enables all Localized strings to be overridden by the main application.
    ///
    /// This method checks the main bundle for a Localized strings file. If one exists, the localized string name will be checked in that file. If one does not exist, the SDK string will be returned.
    ///
    /// If no name is passed in, a default obvious string will be returned. That value is: !&!&!&!&!&!&!&!&!&!&!&!&!&!&!
    ///
    /// - Parameters:
    ///     - name: The key name of the localized string.
    ///     - comment: The value for the key. If no key - value is found, the comment value will be used.
    /// - Returns: A string with either the value from the main bundle or the SDK bundle, else the comment.
    public func getString(forLocalizedName name: String, defaultValue: String) -> String {
        if name.isEmpty {
            return "!&!&!&!&!&!&!&!&!&!&!&!&!&!&!"
        }
        var localString = NSLocalizedString(name, tableName: stringsTableName, bundle: Bundle.main, comment: defaultValue)
        if !localString.isEmpty && localString != name {
            return localString
        }
        guard let sdkBundle = Bundle.getResourcesBundle() else {
            return defaultValue
        }
        // The Main Bundle does not contain the value for the key. Use the SDK strings table.
        localString = NSLocalizedString(name, tableName: "Localizable", bundle: sdkBundle, value: defaultValue, comment: defaultValue)
        if !localString.isEmpty && localString != name {
            return localString
        }
        return defaultValue
    }
    
}

extension NSObject {
    /// Method outputs a debug statement containing necessary information to resolve issues.
    ///
    /// Only works with debug/dev builds.
    ///
    ///  - Parameters:
    ///     - object: Any object type
    ///     - functionName: Automatically populated by the application
    ///     - fileName: Automatically populated by the application
    ///     - lineNumber: Automatically populated by the application
    ///     - message: The message you wish to output.
    public func debugLog(object: Any, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line, message: String) {
        #if DEBUG
        let className = (fileName as NSString).lastPathComponent
        print("\n\n******************\tBegin Debug Log\t******************\n\n\tClass: <\(className)>\n\tFunction: \(functionName)\n\tLine: #\(lineNumber)\n\tObject: \(object)\n\tLog Message: \(message)\n\n******************\tEnd Debug Log\t******************\n\n")
        #endif
    }
}

/// Bundle extension to aid in retrieving the SDK resources for getting SDK images.
extension Bundle {
    /// Will return the Bundle for the SDK if it can be found.
    static func getResourcesBundle() -> Bundle? {
        let bundle = Bundle(for: OSSSpeech.self)
        guard let resourcesBundleUrl = bundle.resourceURL?.appendingPathComponent("OSSSpeechKit.bundle") else {
            return nil
        }
        return Bundle(url: resourcesBundleUrl)
    }
}
