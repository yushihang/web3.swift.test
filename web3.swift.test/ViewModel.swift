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

enum CustomError: Error {
    case withMessage(String)
    
    var localizedDescription: String {
        switch self {
        case .withMessage(let message):
            return message
        }
    }
}



class Web3ViewModel: ObservableObject {
    let web3 = Web3(rpcURL: "HTTP://127.0.0.1:7545")
    
    let privateKey = try! EthereumPrivateKey(hexPrivateKey: "0xf653cbda28c5625ff9c2c9eb40b94dd846d6e68c4f7f8f3d32e5a10832f793f1")
    
    let contractAddressHex = "0xdc5ECDd72a4201D379a976a118a359a02637D30f"
    
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
    
    func getBalance(hex: String) async -> BigUInt? {
        guard let ethAddress = try? EthereumAddress(hex: hex, eip55: true) else {
            return nil
        }
        return try? await withCheckedThrowingContinuation { continuation in
   
            self.web3.eth.getBalance(address: ethAddress, block: .latest) { result in
                switch result.status {
                case .success(let balance):
                    continuation.resume(returning: balance.quantity)
                case .failure(let error):
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
                    maxPriorityFeePerGas: EthereumQuantity(quantity: 1.gwei),
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
    
    func readFromContractFunction() async -> String? {
        
     
        
        guard let contractAddress = try? EthereumAddress(hex: contractAddressHex, eip55: true) else {
            return nil
        }
        
        guard let data = abiJson.data(using: .utf8) else {
            return nil
        }
        
        guard let contract = try? web3.eth.Contract(json: data, abiKey: "abi", address: contractAddress) else {
            return nil
        }
        
        print("contract.methods.count: \(contract.methods.count)")
        
      
        guard let contractFunc = contract["getGISTProof"] else {
            return nil
        }
        
        let holderDIDBigIntString:BigUInt = BigUInt(stringLiteral: "123")

    
        return try? await withCheckedThrowingContinuation { continuation in
            contractFunc(holderDIDBigIntString).call { data, error in
                print("data: \(data ?? [:] )")
                if let error {
                    print("\(#file):\(#line) \(error)")
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let data else {
                    print("\(#file):\(#line) data is nil")
                    continuation.resume(returning: nil)
                    return
                }
                

                continuation.resume(returning: String(describing: data))
                
                
            }
        }
        
        /*

        guard let call = contractFunc().createCall() else {
            return nil
        }
   
        guard let contractFunc = contract["getGISTRootHistoryLength"] else {
            return nil
        }
         
        
  
    
        web3.eth.call(call: call, block: .latest){ response in
            switch response.status {
            case .success(let result):
                print(result)
            case .failure(let error):
                print("\(#file):\(#line) \(error)")
            }
        }
         */
        /*
        contract.call

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
         */

    }
    
    
    func writeToContractFunction() async -> String? {
        
        
        guard let contractAddress = try? EthereumAddress(hex: contractAddressHex, eip55: true) else {
            return nil
        }
        
        guard let data = abiJson.data(using: .utf8) else {
            return nil
        }
        
        guard let contract = try? web3.eth.Contract(json: data, abiKey: "abi", address: contractAddress) else {
            return nil
        }
        
        print("contract.methods.count: \(contract.methods.count)")
        
        
        guard let contractFunc = contract["transitStateGeneric"] else {
            return nil
        }
        return try? await withCheckedThrowingContinuation { continuation in
            firstly {
                self.web3.eth.getTransactionCount(address: self.privateKey.address, block: .latest)
            }
            .then { nonce in
                
                guard let transaction = contractFunc(
                    BigUInt.randomInteger(withMaximumWidth: 200),
                    BigUInt(0),
                    BigUInt(2),
                    true,
                    BigUInt(1),
                    Data()
                )
         
                    .createTransaction(
                        nonce: nonce,
                        gasPrice: EthereumQuantity(quantity: 21.gwei),
                        maxFeePerGas: EthereumQuantity(quantity: 21.gwei),
                        maxPriorityFeePerGas: EthereumQuantity(quantity: 1.gwei),
                        gasLimit: 210000,
                        from: self.privateKey.address,
                        value: 0,
                        accessList: [:],
                        transactionType: .eip1559
                    ) else {
                    throw CustomError.withMessage("create createTransaction failed")
                }
                
                let signedTx = try transaction.sign(with: self.privateKey, chainId: 1337)
                return self.web3.eth.sendRawTransaction(transaction: signedTx)
                
            }.done { hash in
                print("hash: \(hash.hex())")
                continuation.resume(returning: hash.hex())
            }.catch { error in
                print("\(#file):\(#line) \(error)")
                continuation.resume(throwing: error)
            }
        }
    }
    
    
    func checkTxHashHex(txHash: String) async -> String? {
        guard let ethereumData = try? EthereumData.string(txHash) else {
            return nil
        }
        return try? await withCheckedThrowingContinuation { continuation in
            
            self.web3.eth.getTransactionReceipt(transactionHash: ethereumData) { resp in
                switch resp.status {
                case .success(let receipt):
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    guard let jsonData = try? encoder.encode(receipt),
                          let jsonString = String(data: jsonData, encoding: .utf8)
                    else {
                        continuation.resume(returning: nil)
                        return
                    }
                    continuation.resume(returning: jsonString)
                case .failure(let error):
                    print("\(#file):\(#line) \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
