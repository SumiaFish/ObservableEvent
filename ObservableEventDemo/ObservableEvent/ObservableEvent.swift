//
//  ObservableEvent.swift
//  ObservableEventDemo
//
//  Created by 黄凯文
//

import UIKit
import RxSwift

// MARK: - ObservableEvent

protocol ObservableEvent {
    associatedtype Output
    
    func processing() -> Observable<Output>
}

extension ObservableEvent {
    static var eventTypeName: String {
        String(reflecting: type(of: self.self))
    }
}

extension ObservableEvent {
    
    func startExecution() -> Observable<Output> {
        EventDispatcher.shared.executeEvent(self)
    }
    
    static var executionStartPublishSubject: PublishSubject<EventExecutionStart<Self>> {
        EventDispatcher.shared.startProvider.publishSubject(self, elementType: EventExecutionStart<Self>.self)
    }
    
    static var executionSuccessPublishSubject: PublishSubject<EventReceivedOutput<Self>> {
        EventDispatcher.shared.successProvider.publishSubject(self, elementType: EventReceivedOutput<Self>.self)
    }

    static var executionFailurePublishSubject: PublishSubject<EventReceivedError<Self>> {
        EventDispatcher.shared.failureProvider.publishSubject(self, elementType: EventReceivedError<Self>.self)
    }

    static var executionCompletionPublishSubject: PublishSubject<EventExecutionCompleted<Self>> {
        EventDispatcher.shared.completedProvider.publishSubject(self, elementType: EventExecutionCompleted<Self>.self)
    }
    
}

// MARK: - ObservableEventExecution

protocol ObservableEventExecution {
    var status: ObservableEventStatus { get }
}

enum ObservableEventStatus {
    case start
    case success
    case failure
    case completed
}

struct EventExecutionStart<E: ObservableEvent>: ObservableEventExecution {
    let status = ObservableEventStatus.start
    let event: E
}

struct EventReceivedOutput<E: ObservableEvent>: ObservableEventExecution {
    let status = ObservableEventStatus.success
    let event: E
    let output: E.Output
}

struct EventReceivedError<E: ObservableEvent>: ObservableEventExecution {
    let status = ObservableEventStatus.failure
    let event: E
    let error: Error
}

struct EventExecutionCompleted<E: ObservableEvent>: ObservableEventExecution {
    let status = ObservableEventStatus.completed
    let event: E
    let result: Result<E.Output, Error>
}

// MARK: - EventDispatcher

class EventDispatcher {
    
    static let shared = EventDispatcher()
 
    private let disposeBag = DisposeBag()
 
    var isShowLog = true
    
    let startProvider = EventPublishSubjectProvider(subjectStatus: .start)
    
    let successProvider = EventPublishSubjectProvider(subjectStatus: .success)
    
    let failureProvider = EventPublishSubjectProvider(subjectStatus: .failure)
    
    let completedProvider = EventPublishSubjectProvider(subjectStatus: .completed)
    
    private init() {}
    
    func executeEvent<E: ObservableEvent>(_ e: E) -> Observable<E.Output> {
        let observeblle = e.processing().share()

        logEvent(e, observeble: observeblle)
        
        startProvider.publishSubject(type(of: e).self, elementType: EventExecutionStart<E>.self)
            .onNext(.init(event: e))
        
        observeblle
            .subscribe(
                with: self,
                onNext: { (self, val)  in
                    self.successProvider.publishSubject(type(of: e).self, elementType: EventReceivedOutput<E>.self)
                        .onNext(.init(event: e, output: val))
                    
                    self.completedProvider.publishSubject(type(of: e).self, elementType: EventExecutionCompleted<E>.self)
                        .onNext(.init(event: e, result: .success(val)))
                },
                onError: { (self, err) in
                    self.failureProvider.publishSubject(type(of: e).self, elementType: EventReceivedError<E>.self)
                        .onNext(.init(event: e, error: err))
                    
                    self.completedProvider.publishSubject(type(of: e).self, elementType: EventExecutionCompleted<E>.self)
                        .onNext(.init(event: e, result: .failure(err)))
                }
            )
            .disposed(by: disposeBag)
        
        return observeblle
    }
    
    func logEvent<E: ObservableEvent>(_ e: E, observeble: Observable<E.Output>)  {
        if isShowLog {
            print("\(e) will excute")
        }
        observeble
            .subscribe(
                with: self,
                onNext: { (self, val) in
                    if self.isShowLog {
                        print("\(e) success excution")
                    }
                },
                onError: { (self, _) in
                    if self.isShowLog {
                        print("\(e) failed excution")
                    }
                }
            )
            .disposed(by: disposeBag)
    }

}

class EventPublishSubjectProvider {
    
    private let lock = DispatchQueue(label: "EventPublishSubjectProvider.lock")
    
    private lazy var subjects = [String: Any]()
    
    let subjectStatus: ObservableEventStatus
    
    required init(subjectStatus: ObservableEventStatus) {
        self.subjectStatus = subjectStatus
    }
    
    func publishSubject<E: ObservableEvent, I: ObservableEventExecution>(_ eventType: E.Type, elementType: I.Type) -> PublishSubject<I> {
        typealias R = PublishSubject<I>
        let name = eventType.eventTypeName
        var publishSubject: R!
        lock.sync {
            if let subject = subjects[name] as? R {
                publishSubject = subject
            } else {
                publishSubject = R()
                subjects[name] = publishSubject
            }
        }
        return publishSubject
    }
    
}


