//
//  ContentView.swift
//  ConjugatorIII
//
//  Created by localadmin on 23.04.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import SwiftUI
import Combine

let startTouchesPublisher = PassthroughSubject<Moves,Never>()
let stopTouchesPublisher = PassthroughSubject<Void,Never>()

//var index = 0
//var isTouch = false {
//  willSet {
//    index += 1
//    print("index ",index)
//  }
//}

let fontSize:CGFloat = 48
let keysize:CGFloat = 64
let fireRate = 0.1


enum Moves {
  case left
  case right
}

struct Fonts {
    static func futuraCondensedMedium(size:CGFloat) -> Font{
        return Font.custom("Futura-CondensedMedium",size: size)
    }
}

let letters = "abcdefghijklmnopqrstuvwxyz"

struct ContentView: View {
  
  @State private var boxIndex = 0
  @GestureState private var isTapped = false
  @State private var name:String = ""
  
  @State private var boxKey = Array(letters).map {String($0)}
  @State private var isRunning = false
  @State private var direction:Moves!
  
  let timer = Timer.publish(every: fireRate, on: .main, in: .common).autoconnect()
  
  var body: some View {
    return VStack {
      
      Text("Hello World " + String(boxIndex))
        .onReceive(startTouchesPublisher) { ( direct ) in
          self.direction = direct
          self.isRunning = true
      }
      .background(isRunning ? Color.red: Color.clear)
      .onReceive(stopTouchesPublisher) { ( _ ) in
        self.isRunning = false
      }
      .onReceive(timer) { _ in
        if self.isRunning {
          if self.direction == Moves.right {
            self.boxIndex -= 1
            let tmp = self.boxKey[0]
            for i in 0...self.boxKey.count-2 {
              self.boxKey[i] = self.boxKey[i+1]
            }
            self.boxKey[self.boxKey.count-1] = tmp
          }
          if self.direction == Moves.left {
            self.boxIndex += 1
            let tmp = self.boxKey[self.boxKey.count-1 ]
            for i in (0...self.boxKey.count-2).reversed() {
              self.boxKey[i+1] = self.boxKey[i]
            }
            self.boxKey[0] = tmp
          }
          
        }
      }
      HStack {
        ForEach((0 ..< self.boxKey.count), id: \.self) { column in
          Text(self.boxKey[column])
            .font(Fonts.futuraCondensedMedium(size: fontSize))
            .frame(width: keysize, height: keysize, alignment: .center)
            .border(Color.gray)
            .onTapGesture { self.name += self.boxKey[column] }
        }
      }
      HStack {
        Rectangle()
          .fill(Color.yellow)
          .gesture(DragGesture(minimumDistance: 0)
            .updating($isTapped) { (_, isTapped, _) in
              isTapped = true
              startTouchesPublisher.send(Moves.left)
          }
          .onEnded({ ( value ) in
            stopTouchesPublisher.send()
          })
        )
          .frame(width: 128, height: 128, alignment: .center)
        Rectangle()
          .fill(Color.red)
          .frame(width: 128, height: 128, alignment: .center)
          .gesture(DragGesture(minimumDistance: 0)
            .updating($isTapped) { (_, isTapped, _) in
              isTapped = true
              startTouchesPublisher.send(Moves.right)
          }
          .onEnded({ ( value ) in
            stopTouchesPublisher.send()
          })
        )
      }
      TextField("Verb", text: $name)
      .font(Fonts.futuraCondensedMedium(size: fontSize))
      .labelsHidden()
      .frame(width: 256, height: 32, alignment: .center)
    }
  }
}



struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
