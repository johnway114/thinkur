import Foundation
import Testing
@testable import thinkur

@Suite("ObjCExceptionCatcher")
struct ObjCExceptionCatcherTests {
    @Test func normalExecutionReturnsValue() throws {
        let value = try safeObjC {
            return 42
        }
        #expect(value == 42)
    }

    @Test func swiftErrorPropagates() {
        struct CustomError: Error, Equatable {}

        #expect(throws: CustomError.self) {
            try safeObjC {
                throw CustomError()
            }
        }
    }

    @Test func objcExceptionIsCaughtAndThrownAsError() {
        #expect(throws: Error.self) {
            try safeObjC {
                NSException(
                    name: NSExceptionName("TestAudioUnitException"),
                    reason: "Simulated CoreAudio AUHAL failure",
                    userInfo: nil
                ).raise()
            }
        }
    }
}
