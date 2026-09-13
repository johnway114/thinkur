import Foundation
import ObjCExceptionCatcher

/// Safely executes a block that may raise an Objective-C NSException (such as AVAudioEngine internals).
/// Any NSException is caught and converted to a Swift Error, preventing process termination and stack corruption.
@discardableResult
func safeObjC<T>(_ block: () throws -> T) throws -> T {
    var result: T?
    var innerError: Error?

    try ObjCExceptionCatcher.tryExecute {
        do {
            result = try block()
        } catch {
            innerError = error
        }
    }

    if let innerError {
        throw innerError
    }

    guard let unwrapped = result else {
        throw NSError(
            domain: "com.thinkur.AudioError",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Safe operation returned nil without error"]
        )
    }

    return unwrapped
}

/// Safely executes a void block that may raise an Objective-C NSException.
func safeObjC(_ block: () throws -> Void) throws {
    var innerError: Error?

    try ObjCExceptionCatcher.tryExecute {
        do {
            try block()
        } catch {
            innerError = error
        }
    }

    if let innerError {
        throw innerError
    }
}
