//
//  AsyncHelpers.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 09.10.2022.
//

import Combine

public extension AsyncStream {
  /// Factory function that creates an AsyncStream and returns a tuple standing for its inputs and outputs.
  /// It easy the usage of an AsyncStream in a imperative code context.
  /// - Parameter bufferingPolicy: A `Continuation.BufferingPolicy` value to
  ///       set the stream's buffering behavior. By default, the stream buffers an
  ///       unlimited number of elements. You can also set the policy to buffer a
  ///       specified number of oldest or newest elements.
  /// - Returns: the tuple (input, output). The input can be yielded with values, the output can be iterated over
  static func pipe(
    bufferingPolicy: AsyncStream<Element>.Continuation.BufferingPolicy = .unbounded
  ) -> (AsyncStream<Element>.Continuation, AsyncStream<Element>) {
    var continuation: AsyncStream<Element>.Continuation!
    let stream = AsyncStream(bufferingPolicy: bufferingPolicy) { continuation = $0 }
    return (continuation, stream)
  }
}

public extension AsyncThrowingStream {
  /// Factory function that creates an AsyncthrowingStream and returns a tuple standing for its inputs and outputs.
  /// It easy the usage of an AsyncthrowingStream in a imperative code context.
  /// - Parameter bufferingPolicy: A `Continuation.BufferingPolicy` value to
  ///       set the stream's buffering behavior. By default, the stream buffers an
  ///       unlimited number of elements. You can also set the policy to buffer a
  ///       specified number of oldest or newest elements.
  /// - Returns: the tuple (input, output). The input can be yielded with values/errors, the output can be iterated over
  static func pipe(
    bufferingPolicy: AsyncThrowingStream<Element, Error>.Continuation.BufferingPolicy = .unbounded
  ) -> (AsyncThrowingStream<Element, Error>.Continuation, AsyncThrowingStream<Element, Error>) {
    var continuation: AsyncThrowingStream<Element, Error>.Continuation!
    let stream = AsyncThrowingStream<Element, Error>(bufferingPolicy: bufferingPolicy) { continuation = $0 }
    return (continuation, stream)
  }
}

class CombineAsyncStream<Upstream: Publisher>: AsyncSequence {
  typealias Element = Upstream.Output
  typealias AsyncIterator = CombineAsyncStream<Upstream>
  
  func makeAsyncIterator() -> Self {
    return self
  }

  private let stream:
    AsyncThrowingStream<Upstream.Output, Error>

  private lazy var iterator = stream.makeAsyncIterator()
  
  private var cancellable: AnyCancellable?
  public init(_ upstream: Upstream) {
    var subscription: AnyCancellable? = nil
    
    stream = AsyncThrowingStream<Upstream.Output, Error>(Upstream.Output.self) { continuation in
      subscription = upstream
        .handleEvents(
          receiveCancel: {
            continuation.finish(throwing: nil)
          }
        )
        .sink(receiveCompletion: { completion in
          switch completion {
            case .failure(let error):
              continuation.finish(throwing: error)
            case .finished: continuation.finish(throwing: nil)
          }
        }, receiveValue: { value in
          continuation.yield(value)
        })
    }
    
    cancellable = subscription
  }
  
  func cancel() {
    cancellable?.cancel()
    cancellable = nil
  }
}

extension CombineAsyncStream: AsyncIteratorProtocol {
  public func next() async throws -> Upstream.Output? {
    return try await iterator.next()
  }
}

extension Publisher {
  func asyncStream() -> CombineAsyncStream<Self> {
    return CombineAsyncStream(self)
  }
}


class AsyncStreamCombine<Value, Failure: Error>: AsyncSequence {
    typealias Element = Value
    typealias AsyncIterator = AsyncStreamCombine<Value, Failure>
    
    func makeAsyncIterator() -> Self {
        return self
    }
    
    private let stream: AsyncThrowingStream<Value, Error>
    private lazy var iterator = stream.makeAsyncIterator()
    private var subject: CurrentValueSubject<Value, Failure>
    private var cancellable: AnyCancellable?
    
    var value: Value {
        subject.value
    }
    
    public init(_ subject: CurrentValueSubject<Value, Failure>) {
        var subscription: AnyCancellable? = nil
        self.subject = subject
        
        stream = AsyncThrowingStream<Value, Error>(Value.self) { continuation in
            subscription = subject
                .handleEvents(
                    receiveCancel: {
                        continuation.finish(throwing: nil)
                    }
                )
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case let .failure(error):
                            continuation.finish(throwing: error)
                        case .finished:
                            continuation.finish()
                        }
                    },
                    receiveValue: { value in
                        continuation.yield(value)
                    }
                )
        }
        
        cancellable = subscription
    }
    
    func cancel() {
        cancellable?.cancel()
        cancellable = nil
    }
}

extension AsyncStreamCombine: AsyncIteratorProtocol {
    public func next() async throws -> Value? {
      return try await iterator.next()
    }
}

extension CurrentValueSubject {
    func asyncStream() -> AsyncStreamCombine<Output, Failure> {
        return AsyncStreamCombine(self)
    }
}
