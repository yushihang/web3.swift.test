//
//  ViewModel.swift
//  web3.swift.test
//
//  Created by yushihang on 2024/7/17.
//

import Foundation
import SwiftUI
import Web3

import Web3PromiseKit


class Web3ViewModel: ObservableObject {
    let web3 = Web3(rpcURL: "HTTP://127.0.0.1:7545")
    
    let privateKey = try! EthereumPrivateKey(hexPrivateKey: "0xf653cbda28c5625ff9c2c9eb40b94dd846d6e68c4f7f8f3d32e5a10832f793f1")
    
    func getVersion() async -> String? {
      
        return try? await withCheckedThrowingContinuation { continuation in
            web3.clientVersion { result in
                switch result.status {
                case .success(let version):
                    continuation.resume(returning: version)
                case .failure(let error):
                    print("\(#file):\(#line) \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getNetVersion() async -> String? {
        return try? await withCheckedThrowingContinuation { continuation in
            web3.net.version { result in
                switch result.status {
                case .success(let version):
                    continuation.resume(returning: version)
                case .failure(let error):
                    print("\(#file):\(#line) \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func getPeerCount() async -> BigUInt? {
        return try? await withCheckedThrowingContinuation { continuation in
            web3.net.peerCount { result in
                switch result.status {
                case .success(let count):
                    continuation.resume(returning: count.quantity)
                case .failure(let error):
                    print("\(#file):\(#line) \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func signAndSendTx(amount: BigUInt, toHex: String) async -> String? {
        guard let toAddress = try? EthereumAddress(hex: toHex, eip55: true) else {
            return nil
        }
        return try? await withCheckedThrowingContinuation { continuation in
            
            firstly {
                self.web3.eth.gasPrice()
            }.then { gasPrice in
                self.web3.eth.estimateGas(call: EthereumCall(from: self.privateKey.address, to: toAddress, gasPrice: gasPrice, value: EthereumQuantity(quantity: amount.gwei))).map{ ($0, gasPrice) }
            }.then { gas, gasPrice in
                self.web3.eth.getTransactionCount(address: self.privateKey.address, block: .latest).map{ ($0, gasPrice, gas) }
            }.then { nonce, gas, gasPrice in
                
                let tx = EthereumTransaction(
                    nonce: nonce,
                    gasPrice: EthereumQuantity(quantity: 21.gwei),
                    maxFeePerGas: EthereumQuantity(quantity: 21.gwei),
                    maxPriorityFeePerGas: EthereumQuantity(quantity: amount.gwei),
                    gasLimit: 21000,
                    to: toAddress,
                    value: EthereumQuantity(quantity: amount.gwei)
                )
                return try tx.sign(with: self.privateKey, chainId: 1337).promise
            }.then { tx in
                self.web3.eth.sendRawTransaction(transaction: tx)
            }.done { hash in
                print("hash: \(hash.hex())")
                continuation.resume(returning: hash.hex())
            }.catch { error in
                print("\(#file):\(#line) \(error)")
                continuation.resume(throwing: error)
            }
        }
    }

}
