	//
	//  FCLOperation.swift
	//

import Combine
@preconcurrency import Flow
import Foundation

extension FCL: FlowAccessProtocol {

	nonisolated public func executeScriptAtLatestBlock(
		script: Flow.Script,
		arguments: [Flow.Argument]
	) async throws -> Flow.ScriptResponse {
		try await flow.executeScriptAtLatestBlock(script: script, arguments: arguments)
	}

	nonisolated public func getAccountAtLatestBlock(
		address: Flow.Address
	) async throws -> Flow.Account {
		try await flow.getAccountAtLatestBlock(address: address)
	}

	nonisolated public func ping() async throws -> Bool {
		try await flow.ping()
	}

	nonisolated public func getLatestBlockHeader() async throws -> Flow.BlockHeader {
		try await flow.getLatestBlockHeader()
	}

	nonisolated public func getBlockHeaderById(
		id: Flow.ID
	) async throws -> Flow.BlockHeader {
		try await flow.getBlockHeaderById(id: id)
	}

	nonisolated public func getBlockHeaderByHeight(
		height: UInt64
	) async throws -> Flow.BlockHeader {
		try await flow.getBlockHeaderByHeight(height: height)
	}

	nonisolated public func getBlockById(
		id: Flow.ID
	) async throws -> Flow.Block {
		try await flow.getBlockById(id: id)
	}

	nonisolated public func getBlockByHeight(
		height: UInt64
	) async throws -> Flow.Block {
		try await flow.getBlockByHeight(height: height)
	}

	nonisolated public func getCollectionById(
		id: Flow.ID
	) async throws -> Flow.Collection {
		try await flow.getCollectionById(id: id)
	}

	nonisolated public func sendTransaction(
		transaction: Flow.Transaction
	) async throws -> Flow.ID {
		try await flow.sendTransaction(transaction: transaction)
	}

	nonisolated public func getTransactionById(
		id: Flow.ID
	) async throws -> Flow.Transaction {
		try await flow.getTransactionById(id: id)
	}

	nonisolated public func getTransactionResultById(
		id: Flow.ID
	) async throws -> Flow.TransactionResult {
		try await flow.getTransactionResultById(id: id)
	}

	nonisolated public func getAccountByBlockHeight(
		address: Flow.Address,
		height: UInt64
	) async throws -> Flow.Account {
		try await flow.getAccountByBlockHeight(address: address, height: height)
	}

	nonisolated public func getEventsForHeightRange(
		type: String,
		range: ClosedRange<UInt64>
	) async throws -> [Flow.Event.Result] {
		try await flow.getEventsForHeightRange(type: type, range: range)
	}

	nonisolated public func getEventsForBlockIds(
		type: String,
		ids: Set<Flow.ID>
	) async throws -> [Flow.Event.Result] {
		try await flow.getEventsForBlockIds(type: type, ids: ids)
	}

	nonisolated public func getNetworkParameters() async throws -> Flow.ChainID {
		try await flow.getNetworkParameters()
	}
}
