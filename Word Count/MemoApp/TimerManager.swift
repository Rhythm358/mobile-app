//
//  TimerManager.swift
//  Word Count
//


import Foundation
import SwiftUI

class TimerManager: ObservableObject{

    @Published var timerMode: TimerMode = .initial
    @Published var secondsLeft = UserDefaults.standard.integer(forKey: "timerLength")

    var timer = Timer()

    func setTimerLength(minutes: Int){
        let defaults = UserDefaults.standard
        defaults.set(minutes, forKey: "timerLength")
        secondsLeft = minutes
    }

    func start() {
        timerMode = .running
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            if self.secondsLeft == 0 {
                self.reset()
                timer.invalidate()//タイマー停止
            }
            self.secondsLeft -= 1
        })
    }

    func reset(){
        self.timerMode = .initial
        self.secondsLeft = UserDefaults.standard.integer(forKey: "timerLength")
        timer.invalidate()//タイマー停止
    }

    func pause(){
        self.timerMode = .paused
        timer.invalidate()//タイマー停止
    }
}

enum TimerMode{
    case running
    case paused
    case initial
}

func secondsToMinutesAndSeconds(seconds: Int) -> String{

   let minutes = "\((seconds % 36000) / 60)"
   let seconds = "\((seconds % 36000) % 60)"
   let minutesStamp = minutes.count > 1 ? minutes : "0" + minutes
   let secondStamp  = seconds.count > 1 ? seconds : "0" + seconds

   return "\(minutesStamp): \(secondStamp)"
}


