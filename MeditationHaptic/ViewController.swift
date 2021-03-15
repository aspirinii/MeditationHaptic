//
//  ViewController.swift
//  MeditationHaptic
//
//  Created by jk on 3/8/21.
//

import UIKit
import CoreHaptics
import AVFoundation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        createEngine()
    }
    
    var engine: CHHapticEngine?
    var adPlayer: CHHapticAdvancedPatternPlayer!
    // Maintain a variable to check for Core Haptics compatibility on device.
    lazy var supportsHaptics: Bool = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.supportsHaptics
    }()
    
    @IBOutlet weak var exhaleSec: UILabel!
    @IBOutlet weak var exhaleStopSec: UILabel!
    @IBOutlet weak var inhaleSec: UILabel!
    @IBOutlet weak var inhaleStopSec: UILabel!
    
    func createEngine() {
        // Create and configure a haptic engine.
        do {
            // Associate the haptic engine with the default audio session
            // to ensure the correct behavior when playing audio-based haptics.
            let audioSession = AVAudioSession.sharedInstance()
            engine = try CHHapticEngine(audioSession: audioSession)
        } catch let error {
            print("Engine Creation Error: \(error)")
        }
        
        guard let engine = engine else {
            print("Failed to create engine!")
            return
        }
        
        // The stopped handler alerts you of engine stoppage due to external causes.
        engine.stoppedHandler = { reason in
            print("The engine stopped for reason: \(reason.rawValue)")
            switch reason {
            case .audioSessionInterrupt:
                print("Audio session interrupt")
            case .applicationSuspended:
                print("Application suspended")
            case .idleTimeout:
                print("Idle timeout")
            case .systemError:
                print("System error")
            case .notifyWhenFinished:
                print("Playback finished")
            case .gameControllerDisconnect:
                print("Controller disconnected.")
            case .engineDestroyed:
                print("Engine destroyed.")
            @unknown default:
                print("Unknown error")
            }
        }
 
        // The reset handler provides an opportunity for your app to restart the engine in case of failure.
        engine.resetHandler = {
            // Try restarting the engine.
            print("The engine reset --> Restarting now!")
            do {
                try self.engine?.start()
            } catch {
                print("Failed to restart the engine: \(error)")
            }
        }
    }
    
    @IBAction func exhaleUp(_ sender: Any) {
        UpDonwNumber(up: true, label: exhaleSec)
    }
    @IBAction func exhaleStopUP(_ sender: Any) {
        UpDonwNumber(up: true, label: exhaleStopSec)
    }
    @IBAction func inhaleUP(_ sender: Any) {
        UpDonwNumber(up: true, label: inhaleSec)
    }
    @IBAction func inhaleStopUp(_ sender: Any) {
        UpDonwNumber(up: true, label: inhaleStopSec)
    }
    @IBAction func exhaleDown(_ sender: Any) {
        UpDonwNumber(up: false, label: exhaleSec)
    }
    @IBAction func exhaleStopDown(_ sender: Any) {
        UpDonwNumber(up: false, label: exhaleStopSec)
    }
    @IBAction func inhaleDown(_ sender: Any) {
        UpDonwNumber(up: false, label: inhaleSec)
    }
    @IBAction func inhaleStopDown(_ sender: Any) {
        UpDonwNumber(up: false, label: inhaleStopSec)
    }
    @IBAction func playHaptic(_ sender: Any) {
     
//        do {
//          let pattern = try inhalePattern()
//          try playHapticFromPattern(pattern)
//            print("dd")
//        } catch {
//          print("Error name : \(error)")
//        }
        
        timeSchedule()
    }
    @IBAction func Pause(_ sender: Any) {
        do{
        try adPlayer?.pause(atTime: CHHapticTimeImmediate)
        }catch{
            print("error")
        }
//        engine?.stop()
        timer?.invalidate()
    }
    
    func playInhale(){
        do {
          let pattern = try inhalePattern()
          try playHapticControlRate(pattern)
        } catch {
          print("Failed to play Haptic beacuse !! : \(error)")
        }
        print("!")
    }

    func playInhaleStop(){
        do {
          let pattern = try inhaleStopPattern()
          try playHapticFromPattern(pattern)
        } catch {
          print("Failed to play Haptic beacuse !! : \(error)")
        }
        print("@@")
    }
    func playExhale(){
        do {
          let pattern = try exhalePattern()
          try playHapticControlRate(pattern)
        } catch {
          print("Failed to play Haptic beacuse !! : \(error)")
        }
        print("$$$")
    }
    func playExhaleStop(){
        do {
          let pattern = try exhaleStopPattern()
          try playHapticFromPattern(pattern)
        } catch {
          print("Failed to play Haptic beacuse !! : \(error)")
        }
        print("####")
    }
    func textToNumber(label: UILabel)->Int{
        let receiveStr = label.text
        let receiveInt :Int = Int(String(receiveStr!)) ?? 1
        return receiveInt
    }
    
    @objc func hapticBlock(){

        var runCount = 0
        let exhaleSecInt = textToNumber(label: exhaleSec)
        let exhaleStopSecInt = textToNumber(label: exhaleStopSec)
        let inhaleSecInt = textToNumber(label: inhaleSec)
        let inhaleStopSecInt = textToNumber(label: inhaleStopSec)

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if runCount == 0{
                self.playInhale()
            }
            else if runCount == inhaleSecInt {
                self.Pause(1)
                self.playInhaleStop()

            }else if runCount == (inhaleSecInt+inhaleStopSecInt){
                self.Pause(1)
                self.playExhale()

            }else if runCount == (exhaleSecInt+inhaleStopSecInt+inhaleSecInt){
                self.Pause(1)
                self.playExhaleStop()

            }else if runCount == (exhaleSecInt+exhaleStopSecInt+inhaleSecInt+inhaleStopSecInt){
                self.Pause(1)
                timer.invalidate()
 
            }
            print(runCount)
            runCount += 1
        }
    }
    
        
    @objc func fireTimer() {
        
            print("Timer fired!")
    }
    var timer:Timer? = nil

    func timeSchedule(){
        let exhaleSecInt = textToNumber(label: exhaleSec)
        let exhaleStopSecInt = textToNumber(label: exhaleStopSec)
        let inhaleSecInt = textToNumber(label: inhaleSec)
        let inhaleStopSecInt = textToNumber(label: inhaleStopSec)
        
        let sumOfTime = exhaleSecInt + exhaleStopSecInt + inhaleSecInt + inhaleStopSecInt
        let timer = Timer.scheduledTimer(timeInterval: TimeInterval(sumOfTime), target: self, selector: #selector(hapticBlock), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    /// - Tag: CreateEngine


    
    func playHapticFromPattern(_ pattern: CHHapticPattern) throws {
        try engine?.start()
        adPlayer = try engine?.makeAdvancedPlayer(with: pattern)
        adPlayer?.loopEnabled = true
        adPlayer?.loopEnd = 1
        try adPlayer?.start(atTime: CHHapticTimeImmediate)
    }
    
    func playHapticControlRate(_ pattern: CHHapticPattern) throws {
        try engine?.start()
        adPlayer = try engine?.makeAdvancedPlayer(with: pattern)
        adPlayer?.playbackRate = 10/Float(textToNumber(label: inhaleSec))
//        adPlayer?.playbackRate = 2 // 배속임
        try adPlayer?.start(atTime: CHHapticTimeImmediate)
    }
    
    
    
    func UpDonwNumber(up:Bool, label:UILabel){
        let receiveStr = label.text
        var receiveInt :Int = Int(String(receiveStr!)) ?? 1
        if(up){receiveInt += 1}
        else{receiveInt -= 1}

        let sendingStr = String(receiveInt)

        label.text = sendingStr
    }
    

}



extension ViewController {
  private func inhalePattern() throws -> CHHapticPattern {

    let splish1 = CHHapticEvent(
      eventType: .hapticTransient,
      parameters: [
        CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
        CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
      ],
        relativeTime: 0)
    
    let splash = CHHapticEvent(
      eventType: .hapticContinuous,
      parameters: [
        CHHapticEventParameter(parameterID: .hapticIntensity, value: 1),
        CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
      ],
      relativeTime: 0,
        duration: 10)
    
    let curve = CHHapticParameterCurve(
      parameterID: .hapticIntensityControl,
      controlPoints: [
        .init(relativeTime: 0, value: 0.5),
        .init(relativeTime: 0.2, value: 0),
//        .init(relativeTime: 5, value: 0.6),
        .init(relativeTime: 10, value: 1.0)
      ],
        relativeTime: 0)
    

    return try CHHapticPattern(events: [splish1,splash], parameterCurves: [curve])


  }
    
    
    private func inhaleStopPattern() throws -> CHHapticPattern {
        
        let splish1 = CHHapticEvent(
          eventType: .hapticTransient,
          parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
          ],
            relativeTime: 0.5)
        
      let curve = CHHapticParameterCurve(
        parameterID: .hapticIntensityControl,
        controlPoints: [
          .init(relativeTime: 0, value: 1),
          .init(relativeTime: 1, value: 1)
        ],
          relativeTime: 0)
        
        let event = [splish1]
      
      return try CHHapticPattern(events: event, parameterCurves: [curve])
    }
    
    private func exhalePattern() throws -> CHHapticPattern {
        let splash = CHHapticEvent(
          eventType: .hapticContinuous,
          parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 1),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
          ],
          relativeTime: 0,
            duration: 10)
        
        let curve = CHHapticParameterCurve(
          parameterID: .hapticIntensityControl,
          controlPoints: [
            .init(relativeTime: 0, value: 1),
            .init(relativeTime: 5, value: 0.5),
            .init(relativeTime: 10, value: 0)
          ],
            relativeTime: 0)
        

        return try CHHapticPattern(events: [splash], parameterCurves: [curve])
    }
        
    private func exhaleStopPattern() throws -> CHHapticPattern {
        let splish1 = CHHapticEvent(
          eventType: .hapticTransient,
          parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
          ],
            relativeTime: 0.5)
        
      let curve = CHHapticParameterCurve(
        parameterID: .hapticIntensityControl,
        controlPoints: [
          .init(relativeTime: 0, value: 1),
          .init(relativeTime: 1, value: 1)
        ],
          relativeTime: 0)
        
        let event = [splish1]
      
      return try CHHapticPattern(events: event, parameterCurves: [curve])
    }
}
