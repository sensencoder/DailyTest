//: Playground - noun: a place where people can play

import UIKit

func animationApi() {
    let button = UIButton()
    UIView.animate(withDuration: 0.35) {
        button.frame.size = CGSize(width: 200, height: 200)
    }
    // 按钮淡入淡出(复杂)
    UIView.animate(withDuration: 0.35, animations: {
        button.alpha = 1
    }) { _ in
        UIView.animate(withDuration: 0.35) {
            button.frame.size = CGSize(width: 200, height: 200)
        }
    }
}



















