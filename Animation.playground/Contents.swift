//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport
/*第1部分:在Swift中构建声明性动画框架*/
//func animationApi() {
//    let button = UIButton()
//    UIView.animate(withDuration: 0.35) {
//        button.frame.size = CGSize(width: 200, height: 200)
//    }
//    // 按钮淡入淡出(复杂)
//    UIView.animate(withDuration: 0.35, animations: {
//        button.alpha = 1
//    }) { _ in
//        UIView.animate(withDuration: 0.35) {
//            button.frame.size = CGSize(width: 200, height: 200)
//        }
//    }
//    // 实现之前的淡入淡出的动画
//    // 达到以下效果的API
//    /*button.animate([
//        .fadeIn(duration: 0.3),
//        .resize(to: CGSize(width: 200, height: 200), duration: 0.3)
//    ])*/
//
//}
// 声明方式表达动画
public struct Animation {
    public let duration: TimeInterval
    public let closure: (UIView) -> Void
}
// 为Animation添加动画函数
public extension Animation {
    static func fadeIn(duration:TimeInterval = 0.3) -> Animation {
        return Animation(duration: duration, closure: {$0.alpha = 1})
    }
    
    static func resize(to size:CGSize,duration:TimeInterval = 0.3) -> Animation {
        return Animation(duration: duration, closure: {$0.bounds.size = size})
    }
}
// UIView添加扩展
public extension UIView {
    func animate(_ animations:[Animation]){
        // Exit condition: once all animations have been performed, we can return
        guard !animations.isEmpty else {
            return
        }
        // Remove the first animation from the queue
        var animations = animations
        let animation = animations.removeFirst()
        // Perform the animation by calling its closure
        UIView.animate(withDuration: animation.duration, animations: {
                animation.closure(self)
        }) { _ in
             // Recursively call the method, to perform each animation in sequence
            self.animate(animations)
        }
    }
    
    
    func animate(inParallel animations: [Animation]) {
        for animation in animations {
            UIView.animate(withDuration: animation.duration) {
                animation.closure(self)
            }
        }
    }
    
}


let view = UIView(frame: CGRect(
    x: 0, y: 0,
    width: 500, height: 500
))

view.backgroundColor = .white

PlaygroundPage.current.liveView = view

// MARK: - Performing the animation
let animationView = UIView(frame: CGRect(
    x: 0, y: 0,
    width: 50, height: 50
))

animationView.backgroundColor = .red
animationView.alpha = 0
view.addSubview(animationView)

animationView.animate(inParallel: [
    .fadeIn(duration: 3),
    .resize(to: CGSize(width: 200, height: 200), duration: 3)
])




