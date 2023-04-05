# ObservableEvent

`ObservableEvent` is an event dispatcher used to handle a group of events that implement the `ObservableEvent` protocol.

## Usage

### Event Dispatching

The dispatcher provides four `PublishSubject` topics, each corresponding to the start, success, failure, and completion states of the event. The `startProvider`, `successProvider`, `failureProvider`, and `completedProvider` are objects of type `EventPublishSubjectProvider`. These objects provide `PublishSubject` topics through the `publishSubject` method to publish instances of the `ObservableEventExecution` type related to the event. These instances can be of type `EventExecutionStart`, `EventReceivedOutput`, `EventReceivedError`, or `EventExecutionCompleted`.

To dispatch an event, create an instance of the appropriate `ObservableEventExecution` subclass and call the appropriate `onNext()` method on the corresponding `PublishSubject`. For example, to dispatch an `EventExecutionStart` event, create an instance of that class and call `startProvider.publishSubject.onNext(event)`.

### Event Processing

For event processing, the code provides a `processing` method to implement the specific event processing logic. The `processing` method returns an `Observable` object that represents the output result of the event. The `startExecution` method submits the event to the event dispatcher for processing and returns an `Observable` object that can subscribe to the output result of the event.

To process an event, call `startExecution` on the dispatcher with an instance of the appropriate `ObservableEventExecution` subclass. For example, to process an `EventExecutionStart` event, create an instance of that class and call `startExecution(event)`.

### Demo
```
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

// MARK: - Demo

struct TestLoginEvent: ObservableEvent {
    typealias Output = String
    
    let username: String
    let pwd: String
    
    func processing() -> Observable<String> {
        .just("success")
    }
}

class Demo1 {
    let disposeBag = DisposeBag()
    
    init() {
        TestLoginEvent(username: "user", pwd: "pwd")
            .startExecution()
            .subscribe(
                onNext: {
                    print($0)
                }
            )
            .disposed(by: disposeBag)
    }
}

class Demo2 {
    let disposeBag = DisposeBag()
    
    init() {
        TestLoginEvent
            .executionSuccessPublishSubject
            .subscribe(
                onNext: {
                    print("username: \($0.event.username), pwd:\($0.event.pwd), output:\($0.output)")
                }
            )
            .disposed(by: disposeBag)
    }
}
```

## License

`ObservableEvent` is released under the [MIT License](https://opensource.org/licenses/MIT).
