//
//  ReplayKitScreenRecorder.swift
//  ARConcept
//
//  Created by Dmitry Dyachenko on 3/11/21.
//

import Foundation


import ReplayKit
import os.log

// MARK: - Protocol

/// Protocol to add Replay Kit Screen Recording to any UIViewController
/// Example:
/// ~~~
/// class MainViewController: UIViewController, ReplayKitScreenRecorder {
///
/// // MARK: - ReplayKitScreenRecorder Properties
///
/// internal let recorder = RPScreenRecorder.shared()
///
/// ...
///
/// if recordVideoOfSession.isOn {
///     startRecording()
/// }
///
/// ...
///
/// if self.recordVideoOfSession.isOn {
///     stopRecording()
/// }
/// ~~~

public protocol ReplayKitScreenRecorder: UIViewController, RPPreviewViewControllerDelegate {

 var recorder: RPScreenRecorder {
    get
 }

 func startRecording(canceled: @escaping ()->()) 
 func stopRecording()
}

// MARK: - Default Implementation

extension ReplayKitScreenRecorder {

 /// Default implementation for starting screen recording
 /// Example:
 ///         if recordVideoOfSession.isOn {
    //@@objc objc /             startRecording()
 ///         }
    public func startRecording(canceled: @escaping ()->()) {

     guard recorder.isAvailable else {
         os_log(.info, log: .recorder, "ReplayKit Recorder is not available")
         return
     }

     recorder.isMicrophoneEnabled = false

     recorder.startRecording { error in

         guard error == nil else {
             os_log(.error, log: .recorder, "Error starting the recording: '%@'",
                    error?.localizedDescription ?? "")
            canceled()
             return
         }

         os_log(.info, log: .recorder, "Started recording")
     }

 }

 /// Default implementation for stopping screen recording and saving / editing or deleting the video
 /// Example:
 ///         if self.recordVideoOfSession.isOn {
 ///             stopRecording()
 ///         }
 public func stopRecording() {
     recorder.stopRecording { viewController, error in
         os_log(.info, log: .recorder, "Stopped recording")

         if error != nil {
             os_log(.error, log: .recorder, "Error: stopping the recording: '%@'",
                    error?.localizedDescription ?? "")
         }

         guard let preview = viewController else {
             os_log(.error, log: .recorder, "Preview controller is not available")
             return
         }

         let alert = UIAlertController(title: Localized.alertTitle,
                                       message: Localized.alertMessage,
                                       preferredStyle: .alert)

         let deleteAction = UIAlertAction(title: Localized.deleteTitle, style: .destructive) { _ in
             self.recorder.discardRecording  {
                 os_log(.info, log: .recorder, "Recording deleted")
             }
         }

//         let editAction = UIAlertAction(title: Localized.editTitle, style: .default) { _ in
//             os_log(.info, log: .recorder, "Will present Recording edit and save view controller")
//
//             preview.previewControllerDelegate = self
//             self.present(preview, animated: true, completion: nil)
//         }
        let shareAction = UIAlertAction(title: "Share", style: .default, handler: { (action) in
                   // Try .fullScreen
                   preview.modalPresentationStyle = .fullScreen
                   preview.previewControllerDelegate = self
                   self.present(preview, animated: false, completion: nil)
               })

         alert.addAction(deleteAction)
         alert.addAction(shareAction)
         os_log(.info, log: .recorder, "Will present Recording edit or delete action sheet")
         self.present(alert, animated: true, completion: nil)
     }
 }

 private typealias Localized = ScreenRecorderLocalizedString
}

// MARK: - Localized Strings

enum ScreenRecorderLocalizedString {

 static let alertTitle = NSLocalizedString("ddsu_recording_action_sheet_title",
     value: "Recording Finished",
   comment: "The title for screen recorder finished recording action sheet")

 static let alertMessage = NSLocalizedString("ddsu_recording_action_sheet_message",
     value: "Would you like to edit or delete your recording?",
   comment: "The title for screen recorder finished recording action sheet")

 static let editTitle  = NSLocalizedString("ddsu_recording_action_sheet_edit",
     value: "Save or Edit",
   comment: "The title for edit/save button in screen recorder finished recording action sheet")

 static let deleteTitle = NSLocalizedString("ddsu_recording_action_sheet_delete",
     value: "Delete",
   comment: "The title for delete button in screen recorder finished recording action sheet")

}

// MARK: - RPPreviewViewControllerDelegate Support

extension UIViewController {

 @objc func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
     os_log(.info, log: .recorder, "Recording preview controller finished")
     dismiss(animated: true)
  }
}

extension OSLog {
 /// Custom Log object to use when logging **Screen Recorder Lifecycle events**.
    fileprivate static let recorder = OSLog(subsystem: "user_subsystem", category: "Screen Recorder")
}
