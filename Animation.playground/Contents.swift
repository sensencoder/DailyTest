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
    static func fadeIn(duration: TimeInterval = 0.3) -> Animation {
        return Animation(duration: duration) { $0.alpha = 1 }
    }
    
    static func fadeOut(duration: TimeInterval = 0.3) -> Animation {
        return Animation(duration: duration) { $0.alpha = 0 }
    }
    
    static func resize(to size: CGSize, duration: TimeInterval = 0.3) -> Animation {
        return Animation(duration: duration) { $0.bounds.size = size }
    }
    
    static func move(byX x: CGFloat, y: CGFloat, duration: TimeInterval = 0.3) -> Animation {
        return Animation(duration: duration) {
            $0.center.x += x
            $0.center.y += y
        }
    }
}
// UIView添加扩展
//public extension UIView {
//    func animate(_ animations:[Animation]){
//        // Exit condition: once all animations have been performed, we can return
//        guard !animations.isEmpty else {
//            return
//        }
//        // Remove the first animation from the queue
//        var animations = animations
//        let animation = animations.removeFirst()
//        // Perform the animation by calling its closure
//        UIView.animate(withDuration: animation.duration, animations: {
//                animation.closure(self)
//        }) { _ in
//             // Recursively call the method, to perform each animation in sequence
//            self.animate(animations)
//        }
//    }
//
//
//    func animate(inParallel animations: [Animation]) {
//        for animation in animations {
//            UIView.animate(withDuration: animation.duration) {
//                animation.closure(self)
//            }
//        }
//    }
//
//}


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

//animationView.animate(inParallel: [
//    .fadeIn(duration: 3),
//    .resize(to: CGSize(width: 200, height: 200), duration: 3)
//])
// We add an enum to describe in which mode we want to animate
// internal public private
internal enum AnimationMode {
    case inSequence // 顺序
    case inParallel // 并行
}
public func animate(_ tokens: [AnimationToken]) {
    guard !tokens.isEmpty else {
        return
    }
    
    var tokens = tokens
    let token = tokens.removeFirst()
    
    token.perform {
        animate(tokens)
    }
}
public func animate(_ tokens: AnimationToken...) {
    animate(tokens)
}
//final 关键字可以用在 class，func 或者 var 前面进行修饰，表示不允许对该内容进行继承或者重写操作。
public final class AnimationToken {
    private let view:UIView
    private let animations:[Animation]
    private let mode:AnimationMode
    private var isValid = true
    
    internal init(view:UIView,animations:[Animation],mode:AnimationMode) {
        self.view = view
        self.animations = animations
        self.mode = mode
    }
    //当Token被释放时自动执行动画
    deinit {
        perform {}
    }
    func perform(completionHandler:@escaping() -> Void){
        guard isValid else {
            return
        }
        isValid = false
        
        switch mode {
        case .inSequence:
            view.performAnimations(animations, completionHandler: completionHandler)
        case .inParallel:
            view.performAnimationsInParallel(animations, completionHandler: completionHandler)
        }
    }
    
}

public extension UIView {
    @discardableResult func animate(_ animations:[Animation]) -> AnimationToken {
        return AnimationToken(view: self, animations: animations, mode: .inSequence)
    }
    @discardableResult func animate(_ animations: Animation...) -> AnimationToken {
        return animate(animations)
    }
    @discardableResult func animate(inParallel animations: [Animation]) -> AnimationToken {
        return AnimationToken(
            view: self,
            animations: animations,
            mode: .inParallel
        )
    }
    
    @discardableResult func animate(inParallel animations: Animation...) -> AnimationToken {
        return animate(inParallel: animations)
    }
    
}

internal extension UIView {
    func performAnimations(_ animations:[Animation],completionHandler:@escaping()->Void) {
        guard !animations.isEmpty else {
            return completionHandler()
        }
        
        var animations = animations
        let animation = animations.removeFirst()
        
        UIView.animate(withDuration: animation.duration, animations: {
            animation.closure(self)
        }, completion: { _ in
            self.performAnimations(animations, completionHandler: completionHandler)
        })
    }
    
    func performAnimationsInParallel(_ animations: [Animation], completionHandler: @escaping () -> Void) {
        guard !animations.isEmpty else {
            return completionHandler()
        }
        
        let animationCount = animations.count
        var completionCount = 0
        
        let animationCompletionHandler = {
            completionCount += 1
            
            if completionCount == animationCount {
                completionHandler()
            }
        }
        
        for animation in animations {
            UIView.animate(withDuration: animation.duration, animations: {
                animation.closure(self)
            }, completion: { _ in
                animationCompletionHandler()
            })
        }
    }
    
}

let label = UILabel()
label.text = "Let's animate..."
label.sizeToFit()
label.center = view.center
label.alpha = 0
view.addSubview(label)


let button = UIButton(type: .system)
button.setTitle("...multiple views!", for: .normal)
button.sizeToFit()
button.center.x = view.center.x
button.center.y = label.frame.maxY + 50
button.alpha = 0
view.addSubview(button)



animate(
    label.animate(
        .fadeIn(duration: 3),
        .move(byX: 0, y: -50, duration: 3)
    ),
    button.animate(.fadeIn(duration: 3))
)






