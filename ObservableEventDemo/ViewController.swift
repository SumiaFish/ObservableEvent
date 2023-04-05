//
//  ViewController.swift
//  ObservableEventDemo
//
//  Created by 黄凯文 on 2023/4/5.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        view.backgroundColor = .white
        
        //
        let loginButton = UIButton(type: .system)
        view.addSubview(loginButton)
        loginButton.setTitle("login", for: .normal)
        loginButton.frame = CGRect(x: 0, y: 100, width: 60, height: 40)
        loginButton.addTarget(self, action: #selector(toLoginPage), for: .touchUpInside)
        
        //
        addObserve()
    }
    
    func addObserve() {
        TestLoginEvent
            .executionSuccessPublishSubject
            .subscribe(
                onNext: {
                    print("ViewController loginSucc: username-\($0.event.username), pwd-\($0.event.pwd), output-\($0.output)")
                }
            )
            .disposed(by: disposeBag)
    }
    
    @objc func toLoginPage() {
        present(LoginViewController(), animated: true)
    }


}

class LoginViewController: UIViewController {
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lightGray
        
        login()
    }
    
    func login() {
        TestLoginEvent(username: "user", pwd: "pwd")
            .startExecution()
            .subscribe(
                onNext: {
                    print("LoginViewController loginSucc: \($0)")
                }
            )
            .disposed(by: disposeBag)
    }


}

// MARK: - Demo

struct TestLoginEvent: ObservableEvent {
    typealias Output = String
    
    let username: String
    let pwd: String
    
    func processing() -> Observable<String> {
        .just("success")
    }
}

