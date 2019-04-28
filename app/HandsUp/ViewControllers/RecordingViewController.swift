//
//  ViewController.swift
//  HandsUp
//
//  Created by Yazan Arafeh on 3/7/19.
//  Copyright © 2019 Team07. All rights reserved.
//

import UIKit
import Speech

class RecordingViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    // MARK: Properties
    @IBOutlet weak var questionAnswerView: UITextView!
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var leaveButton: UIButton!
    
    let defaults = UserDefaults.standard
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Round button and text field
        cancelButton.layer.cornerRadius = 4
        submitButton.layer.cornerRadius = 4
        recordButton.layer.cornerRadius = 4
        questionAnswerView.layer.cornerRadius = 4
        leaveButton.layer.cornerRadius = 4
        leaveButton.sizeToFit()
        
        recordButton.isEnabled = false
        cancelButton.isEnabled = false
        submitButton.isEnabled = false
        
        speechRecognizer.delegate = self
        
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
    }
    
    @IBAction func recordButtonTapped(_ sender: AnyObject) {
        if audioEngine.isRunning {  // When recording is active
            audioEngine.stop()
            recognitionRequest?.endAudio()
            recordButton.isEnabled = false
            recordButton.setTitle("Start Recording", for: .normal)
            recordButton.backgroundColor = self.view.tintColor
            cancelButton.isEnabled = true
            submitButton.isEnabled = true
            
        } else {    // When recording is not active
            startRecording()
            recordButton.setTitle("Stop Recording", for: .normal)
            recordButton.backgroundColor = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1)
            submitButton.isEnabled = false
            cancelButton.isEnabled = true
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        // Stop recording audio
        audioEngine.stop()
        recognitionRequest?.endAudio()
        
        // Reset question answer text field
        questionAnswerView.text = "Press the button below to start recording. Anything you say will appear here."
        submitButton.isEnabled = false
        recordButton.isEnabled = true
        recordButton.setTitle("Start Recording", for: .normal)
        recordButton.backgroundColor = self.view.tintColor
    }
    
    @IBAction func submitButtonTapped(_ sender: Any)
    {
        let data: [String: Any] = ["code": Connection.classCode, "dialog": questionAnswerView.text]
        Connection.socket.emit("dialog",data)
    }
    
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
        
        if (defaults.bool(forKey: "isStudent")) {       // If user is a student, change alert message and button title
            alertController = UIAlertController(title: studentLeaveTitle, message: studentLeaveMessage, preferredStyle: .alert)
            leaveAction = UIAlertAction(title: "Leave", style: .destructive, handler: {(action) in self.leaveAlertActionTapped()})
        }
        else {                                          // If user is professor, change alert message and button title
            alertController = UIAlertController(title: professorEndTitle, message: professorEndMessage, preferredStyle: .alert)
            leaveAction = UIAlertAction(title: "End Session", style: .destructive, handler: {(action) in self.leaveAlertActionTapped()})
        }
        
        // Add buttons to alert
        alertController.addAction(cancelAction)
        alertController.addAction(leaveAction)
        
        // Present alert to user
        present(alertController, animated: true)
    }
    
    func leaveAlertActionTapped() {
        
        if (defaults.bool(forKey: "isStudent")) {
            // TODO: Add code for student leaving session
        }
        else {
            // TODO: Add code for professor ending session
        }
        questionAnswerView.text = "Press the button below to start recording. Anything you say will appear here."
        self.dismiss(animated: true, completion: nil)
    }
    
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
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            recordButton.isEnabled = true
        } else {
            recordButton.isEnabled = false
        }
    }
}
