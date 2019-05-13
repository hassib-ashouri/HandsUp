//
//  ViewController.swift
//  HandsUp
//
//  Copyright © 2019 Team07. All rights reserved.
//

import UIKit
import Speech

class RecordingViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    // MARK: Properties
    // Text views
    @IBOutlet weak var questionAnswerView: UITextView!
    
    // Buttons
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var leaveButton: UIButton!
    
    // Labels
    @IBOutlet weak var sessionCodeLabel: UILabel!
    
    let defaults = UserDefaults.standard
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // Initialize all buttons, labels, and check for user permission to record and recognize speech
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Round button and text field
        cancelButton.layer.cornerRadius = 4
        submitButton.layer.cornerRadius = 4
        recordButton.layer.cornerRadius = 4
        questionAnswerView.layer.cornerRadius = 4
        leaveButton.layer.cornerRadius = 4
        // Check if the user is a student and change the leave button accordingly
        if (!defaults.bool(forKey: "isStudent")){
            leaveButton.setTitle("End Session", for: .normal)
        }
        leaveButton.sizeToFit()
        sessionCodeLabel.text = "Session Code: "
        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
            if SessionViewController.joined == .joined
            {
                // Display correct class code if joined successfuly
                self.sessionCodeLabel.text = "Session Code: " + Connection.classCode
            }
            else
            {
                // Show alert to user that the session code is invalid and go back if the class does not exist.
                let alertController = UIAlertController(
                    title: "Invalid Session Code",
                    message: "Session code does not exist",
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler:{ alert in
                    self.dismiss(animated: true, completion: nil)
                    SessionViewController.joined = .noanswer
                }))
                self.present(alertController, animated: true, completion: nil)
            }
            
        })
        
        recordButton.isEnabled = false
        cancelButton.isEnabled = false
        submitButton.isEnabled = false
        
        speechRecognizer.delegate = self
        
        // Check permission from user to use speech recognition
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            @unknown default:
                print("Speech recognition unavailable")
            }
            
            OperationQueue.main.addOperation() {
                self.recordButton.isEnabled = isButtonEnabled
            }
        }
        
        // Leave the session
        Connection.socket.on("leave"){data, ack in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    /**
        Button handler that starts and stops recording
    */
    @IBAction func recordButtonTapped(_ sender: AnyObject) {
        if audioEngine.isRunning {  // When recording is active
            // Stop recording and reset record button
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordButton.isEnabled = false
            recordButton.setTitle("Start Recording", for: .normal)
            recordButton.backgroundColor = self.view.tintColor
            cancelButton.isEnabled = true
            submitButton.isEnabled = true
            
        } else {    // When recording is not active
            // Start recording and change record button to indicate that recording is active
            startRecording()
            recordButton.setTitle("Stop Recording", for: .normal)
            recordButton.backgroundColor = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1)
            submitButton.isEnabled = false
            cancelButton.isEnabled = true
        }
    }
    
    /**
        Button handler that cancels and deletes current recording
    */
    @IBAction func cancelButtonTapped(_ sender: Any) {
        // Stop recording audio
        audioEngine.stop()
        recognitionRequest?.endAudio()
        
        // Reset Q&A text field
        questionAnswerView.text = "Press the button below to start recording. Anything you say will appear here."
        submitButton.isEnabled = false
        recordButton.isEnabled = true
        recordButton.setTitle("Start Recording", for: .normal)
        recordButton.backgroundColor = self.view.tintColor
    }
    
    /**
        Button handler that submits Q&As to be saved
    */
    @IBAction func submitButtonTapped(_ sender: Any)
    {
        let data: [String: Any] = ["code": Connection.classCode, "dialog": questionAnswerView.text]
        Connection.socket.emit("dialog",data)
    }
    
    /**
        Button handler for leaving/ending the session
     */
    @IBAction func leaveButtonTapped(_ sender: Any) {
        // Student alert strings
        let studentLeaveTitle = "Are you sure you want to leave?"
        let studentLeaveMessage = "Anything that has not been submitted will be deleted."
        
        // Professor alert strings
        let professorEndTitle = "Are you sure you want to end the session?"
        let professorEndMessage = "Anything that has not been submitted by you or the students will be deleted."
        
        // Create alert and buttons
        var alertController = UIAlertController.init()
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        var leaveAction = UIAlertAction.init()
        
        // Check user type and set alert message and buttons
        if (defaults.bool(forKey: "isStudent")) {       // If user is a student
            alertController = UIAlertController(title: studentLeaveTitle, message: studentLeaveMessage, preferredStyle: .alert)
            leaveAction = UIAlertAction(title: "Leave", style: .destructive, handler: {(action) in self.leaveAlertActionTapped()})
        }
        else {                                          // If user is professor
            alertController = UIAlertController(title: professorEndTitle, message: professorEndMessage, preferredStyle: .alert)
            leaveAction = UIAlertAction(title: "End Session", style: .destructive, handler: {(action) in self.leaveAlertActionTapped()})
        }
        
        // Add buttons to alert
        alertController.addAction(cancelAction)
        alertController.addAction(leaveAction)
        
        // Present alert to user
        present(alertController, animated: true)
    }
    
    /**
        Handler for clicking leave on leave session alert popup
    */
    func leaveAlertActionTapped() {
        let jsonLoad: [String:Any] = ["code": Connection.classCode]
        SessionViewController.joined = .noanswer
        if (defaults.bool(forKey: "isStudent")) {
            // Student leaving session
            Connection.socket.emit("leave", jsonLoad)
        }
        else {
            // Professor ending session
            Connection.socket.emit("terminate", jsonLoad)
        }
        questionAnswerView.text = "Press the button below to start recording. Anything you say will appear here."
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
        Function for starting the recording and speech recognition
    */
    func startRecording() {
        
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        
        recognitionRequest.shouldReportPartialResults = true  //6
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
            var isFinal = false  //8
            
            if result != nil {
                
                self.questionAnswerView.text = result?.bestTranscription.formattedString  //9
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {  //10
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()  //12
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        questionAnswerView.text = "Say something, I'm listening!"
        
    }
    
    /**
        Checks status of speech recognition service and enables/disables button accordingly
    */
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
        } else {
            recordButton.isEnabled = false
        }
    }
}
