import AVFAudio
import Foundation
import Testing
@testable import thinkur

@Suite("AudioCaptureManagerTests")
struct AudioCaptureManagerTests {
    @Test func stopCaptureWhenNotCapturingReturnsEmpty() {
        let manager = AudioCaptureManager()
        let samples = manager.stopCapture()
        #expect(samples.isEmpty)
        #expect(!manager.isCapturing)
        #expect(manager.currentAudioLevel == 0)
    }

    @Test func simulatedConfigurationChangeDoesNotCrashWhenIdle() async {
        let manager = AudioCaptureManager()
        // Post notification while idle — should be completely ignored and safe
        NotificationCenter.default.post(
            name: .AVAudioEngineConfigurationChange,
            object: nil
        )
        try? await Task.sleep(nanoseconds: 50_000_000)
        #expect(!manager.isCapturing)
    }

    @Test func repeatedStopCaptureIsIdempotent() {
        let manager = AudioCaptureManager()
        _ = manager.stopCapture()
        _ = manager.stopCapture()
        _ = manager.stopCapture()
        #expect(!manager.isCapturing)
        #expect(manager.currentAudioLevel == 0)
    }
}
