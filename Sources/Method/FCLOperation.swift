//
//  FCLOperation.swift
//
//  Created by lmcmz on 3/11/21.
//

import Combine
@preconcurrency import Flow
import Foundation

@MainActor
extension FCL: FlowAccessProtocol {
    public func executeScriptAtLatestBlock(script: Flow.Script, arguments: [Flow.Argument]) async throws -> Flow.ScriptResponse {
        try await flow.executeScriptAtLatestBlock(script: script, arguments: arguments)
    }

    public func getAccountAtLatestBlock(address: Flow.Address) async throws -> Flow.Account {
        try await flow.getAccountAtLatestBlock(address: address)
    }

    public func ping() async throws -> Bool {
        try await flow.ping()
    }

    public func getLatestBlockHeader() async throws -> Flow.BlockHeader {
        try await flow.getLatestBlockHeader()
    }

    public func getBlockHeaderById(id: Flow.ID) async throws -> Flow.BlockHeader {
        try await flow.getBlockHeaderById(id: id)
    }

    public func getBlockHeaderByHeight(height: UInt64) async throws -> Flow.BlockHeader {
        try await flow.getBlockHeaderByHeight(height: height)
    }

    public func getBlockById(id: Flow.ID) async throws -> Flow.Block {
        try await flow.getBlockById(id: id)
    }

    public func getBlockByHeight(height: UInt64) async throws -> Flow.Block {
        try await flow.getBlockByHeight(height: height)
    }

    public func getCollectionById(id: Flow.ID) async throws -> Flow.Collection {
        try await flow.getCollectionById(id: id)
    }

    public func sendTransaction(transaction: Flow.Transaction) async throws -> Flow.ID {
        try await flow.sendTransaction(transaction: transaction)
    }

    public func getTransactionById(id: Flow.ID) async throws -> Flow.Transaction {
        try await flow.getTransactionById(id: id)
    }

    public func getTransactionResultById(id: Flow.ID) async throws -> Flow.TransactionResult {
        try await flow.getTransactionResultById(id: id)
    }

    public func getAccountByBlockHeight(address: Flow.Address, height: UInt64) async throws -> Flow.Account {
        try await flow.getAccountByBlockHeight(address: address, height: height)
    }

    public func getEventsForHeightRange(type: String, range: ClosedRange<UInt64>) async throws -> [Flow.Event.Result] {
        try await flow.getEventsForHeightRange(type: type, range: range)
    }

    public func getEventsForBlockIds(type: String, ids: Set<Flow.ID>) async throws -> [Flow.Event.Result] {
        try await flow.getEventsForBlockIds(type: type, ids: ids)
    }

    public func getNetworkParameters() async throws -> Flow.ChainID {
        try await flow.getNetworkParameters()
    }

    public func getAccount(address: String) async throws -> Flow.Account {
        try await flow.getAccountAtLatestBlock(address: Flow.Address(hex: address))
    }

    public func getBlock(blockId: String) async throws -> Flow.Block {
        try await flow.getBlockById(id: Flow.ID(hex: blockId))
    }

    public func getLatestBlock(sealed: Bool = true) async throws -> Flow.Block {
        try await flow.getLatestBlock(sealed: sealed)
    }

    public func getBlockHeader(blockId: String) async throws -> Flow.BlockHeader {
        try await flow.getBlockHeaderById(id: Flow.ID(hex: blockId))
    }

    public func getTransactionStatus(transactionId: String) async throws -> Flow.TransactionResult {
        try await flow.getTransactionResultById(id: Flow.ID(hex: transactionId))
    }

    public func getTransaction(transactionId: String) async throws -> Flow.Transaction {
        try await flow.getTransactionById(id: Flow.ID(hex: transactionId))
    }
}
