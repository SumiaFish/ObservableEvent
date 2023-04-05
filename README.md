# ObservableEvent

`ObservableEvent` is an event dispatcher used to handle a group of events that implement the `ObservableEvent` protocol.

## Usage

### Event Dispatching

The dispatcher provides four `PublishSubject` topics, each corresponding to the start, success, failure, and completion states of the event. The `startProvider`, `successProvider`, `failureProvider`, and `completedProvider` are objects of type `EventPublishSubjectProvider`. These objects provide `PublishSubject` topics through the `publishSubject` method to publish instances of the `ObservableEventExecution` type related to the event. These instances can be of type `EventExecutionStart`, `EventReceivedOutput`, `EventReceivedError`, or `EventExecutionCompleted`.

To dispatch an event, create an instance of the appropriate `ObservableEventExecution` subclass and call the appropriate `onNext()` method on the corresponding `PublishSubject`. For example, to dispatch an `EventExecutionStart` event, create an instance of that class and call `startProvider.publishSubject.onNext(event)`.

### Event Processing

For event processing, the code provides a `processing` method to implement the specific event processing logic. The `processing` method returns an `Observable` object that represents the output result of the event. The `startExecution` method submits the event to the event dispatcher for processing and returns an `Observable` object that can subscribe to the output result of the event.

To process an event, call `startExecution` on the dispatcher with an instance of the appropriate `ObservableEventExecution` subclass. For example, to process an `EventExecutionStart` event, create an instance of that class and call `startExecution(event)`.

## License

`ObservableEvent` is released under the [MIT License](https://opensource.org/licenses/MIT).