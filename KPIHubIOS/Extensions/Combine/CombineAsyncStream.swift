//
//  CombineAsyncStream.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Foundation
import Combine

// https://trycombine.com/posts/combine-async-sequence-2/
final class CombineAsyncStream<Upstream: Publisher>: AsyncSequence {
    typealias Element = Upstream.Output
    typealias AsyncIterator = CombineAsyncStream<Upstream>
    
    private let stream: AsyncThrowingStream<Upstream.Output, Error>
    private lazy var iterator = stream.makeAsyncIterator()
    private var cancellable: AnyCancellable?
    
    init(_ upstream: Upstream) {
        var subscription: AnyCancellable?
        
        stream = AsyncThrowingStream<Upstream.Output, Error>(Upstream.Output.self) { continuation in
            subscription = upstream
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
                            continuation.finish(throwing: nil)
                        }
                    },
                    receiveValue: { value in
                        continuation.yield(value)
                    }
                )
        }
        
        cancellable = subscription
    }
    
    func makeAsyncIterator() -> Self {
        self
    }
    
    func cancel() {
        cancellable?.cancel()
        cancellable = nil
    }
}

extension CombineAsyncStream: AsyncIteratorProtocol {
    func next() async throws -> Upstream.Output? {
        try await iterator.next()
    }
}

extension Publisher {
    func asyncStream() -> CombineAsyncStream<Self> {
        CombineAsyncStream(self)
    }
}
