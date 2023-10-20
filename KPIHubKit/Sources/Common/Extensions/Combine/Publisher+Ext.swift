//
//  Publisher+Ext.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 30.06.2022.
//

import Combine

extension Publisher {

    func on(
        value: ((Output) -> Void)? = nil,
        error: ((Failure) -> Void)? = nil,
        finished: (() -> Void)? = nil
    ) -> AnyPublisher<Output, Failure> {
        handleEvents(
            receiveOutput: { output in
                value?(output)
            },
            receiveCompletion: { completion in
                switch completion {
                case .failure(let failure):
                    error?(failure)
                case .finished:
                    finished?()
                }
            }
        )
        .eraseToAnyPublisher()
    }

    func sink() -> AnyCancellable {
        sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    }

}

extension Publisher where Output == Never {

    func setOutputType<NewOutput>(to _: NewOutput.Type) -> AnyPublisher<NewOutput, Failure> {
        func absurd<A>(_ never: Never) -> A {}
        return self.map(absurd).eraseToAnyPublisher()
    }

}

extension Publisher {

    func ignoreOutput<NewOutput>(
        setOutputType: NewOutput.Type
    ) -> AnyPublisher<NewOutput, Failure> {
        self
            .ignoreOutput()
            .setOutputType(to: NewOutput.self)
    }

    func ignoreFailure<NewFailure>(
        setFailureType: NewFailure.Type
    ) -> AnyPublisher<Output, NewFailure> {
        self
            .catch { _ in Empty() }
            .setFailureType(to: NewFailure.self)
            .eraseToAnyPublisher()
    }

    func ignoreFailure() -> AnyPublisher<Output, Never> {
        self
            .catch { _ in Empty() }
            .setFailureType(to: Never.self)
            .eraseToAnyPublisher()
    }

}
