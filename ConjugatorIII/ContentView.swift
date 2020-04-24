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
var fireRate = 0.2
var firstKey = true


enum Moves {
  case left
  case right
}

struct Fonts {
  static func futuraCondensedMedium(size:CGFloat) -> Font{
    return Font.custom("Futura-CondensedMedium",size: size)
  }
}

let letters = "abcdefghijklm<nopqrstuvwxyz "

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
      
    
        
 
       Rectangle()
          .fill(Color.gray)
          .frame(width: 256, height: 16, alignment: .center)
          .onTapGesture {
            stopTouchesPublisher.send()
        }
        .gesture(DragGesture(minimumDistance: 0)
        .updating($isTapped) { (value, isTapped, _) in
          isTapped = true
          if value.translation.width > 10.0 {
            startTouchesPublisher.send(Moves.left)
          }
          if value.translation.width < 10.0 {
            startTouchesPublisher.send(Moves.right)
            print("value ",abs(value.translation.width))
          }
          UIApplication.shared.endEditing()
        }
        .onEnded({ ( value ) in
          //            stopTouchesPublisher.send()
        })
        ).onReceive(startTouchesPublisher) { ( direct ) in
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
            .onTapGesture {
              if self.boxKey[column] == "<" {
                if !self.name.isEmpty {
                  self.name.removeLast()
                } else {
                  firstKey = true
                }
                return
              }
              if firstKey {
                switch self.boxKey[column] {
                case "j":
                  self.name = "Je "
                case "t":
                  self.name = "Tu "
                case "i":
                  self.name = "Il "
                case "e":
                  self.name = "Elle "
                case "n":
                  self.name = "Nous "
                case "v":
                  self.name = "Vous "
                default:
                  break
                  // do nothing
                }
                firstKey = false
              } else {
                self.name += self.boxKey[column]
              }
          }
        }
      
}
        
       
      
//      TextField("Verb", text: $name, onCommit: {
//        print("fooBar")
//      })
      Text(name)
        .font(Fonts.futuraCondensedMedium(size: fontSize))
        .labelsHidden()
        .frame(width: 256, height: 32, alignment: .center)
    }.onTapGesture {
      UIApplication.shared.endEditing()
    }
  }
}

extension UIApplication {
  func endEditing() {
    sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}



struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}


