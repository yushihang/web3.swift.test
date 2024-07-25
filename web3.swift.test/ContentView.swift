//
//  ContentView.swift
//  web3.swift.test
//
//  Created by yushihang on 2024/7/17.
//

import SwiftUI
import Web3

struct ContentView: View {
    
    @ObservedObject var viewModel = Web3ViewModel()
    
    let otherAddress = "0xC0B05B621Ab20123bfC52186708444c783351e69"
    @State var version = ""
    
    @State var netVersion = ""
    
    @State var peerCount: Int64 = -1
    
    @State var balance : BigUInt = BigUInt()
    
    @State var txHash = ""
    
    @State var txHashCheckResult = ""
    
    @State var readContractFunctionResult = ""
    
    @State var writeContractFunctionTxHash = ""
    
    @State var writeContractFunctionTxHashCheckResult = ""
    

    
    var versionNode: some View {
        Group{
            Button {
                Task{
                    version = await viewModel.getVersion() ?? "Error"
                }
            } label: {
                Text("Get Web3 Version")
            }
            
            Text("Version: \(version)")
        }

    }
    
    var netVersionNode: some View {
        Group{
            Button {
                Task{
                    netVersion = await viewModel.getNetVersion() ?? "Error"
                }
            } label: {
                Text("Get Net Version")
            }
            
            Text("Net Version: \(netVersion)")
        }
    }
    
    
    var peerCountNode: some View {
        Group{
            Button {
                Task{
                    peerCount = Int64(await viewModel.getPeerCount() ?? 0)
                }
            } label: {
                Text("Get Peer Count")
            }
            
            Text("Peer Count: \(peerCount)")
        }
    }
    
    var balanceNode: some View {
        Group{
            Button {
                Task{
                    balance = await viewModel.getBalance(hex: otherAddress) ?? BigUInt()
                }
            } label: {
                Text("Get Balance of Specified Account")
            }
            
            Text("balance: \(balance)")
        }
    }
    
    var signAndSendTxNode: some View {
        Group{
            Button {
                Task{
                    txHash = await viewModel.signAndSendTx(amount: 12345, toHex: otherAddress) ?? "Error"
                    
                    balance = await viewModel.getBalance(hex: otherAddress) ?? BigUInt()
                }
            } label: {
                Text("Sign & Send Tx")
            }
            
            Text("tx hash: \(txHash)")
        }
    }
    
    var checkSignAndSendTxHashNode: some View {
        Group{
            Button {
                Task{
                    txHashCheckResult = await viewModel.checkTxHashHex(txHash: txHash) ?? "Error"
                }
            } label: {
                Text("Sign & Send Tx Check")
            }
            
            Text("Sign & Send Tx Check: \(txHashCheckResult)")
        }
    }
    
    
    var readFromContractFunctionNode: some View {
        Group{
            Button {
                Task{
                    readContractFunctionResult = await viewModel.readFromContractFunction() ?? "Error"
                }
            } label: {
                Text("Read Data from Contract Functions")
            }
            
            Text("result: \(readContractFunctionResult)")
        }
    }
    
    var writeToContractFunctionNode: some View {
        Group{
            Button {
                Task{
                    writeContractFunctionTxHash = await viewModel.writeToContractFunction() ?? "Error"
                }
            } label: {
                Text("write To Contract Functions")
            }
            
            Text("result: \(writeContractFunctionTxHash)")
        }
    }
    
    var checkWriteToContractFunctionNode: some View {
        Group{
            Button {
                Task{
                    writeContractFunctionTxHashCheckResult = await viewModel.checkTxHashHex(txHash: writeContractFunctionTxHash) ?? "Error"
                }
            } label: {
                Text("write To Contract Functions Tx Check")
            }
            
            Text("write To Contract Functions Tx Check: \(writeContractFunctionTxHashCheckResult)")
        }
    }
    
    var body: some View {
        ScrollView{
            VStack(spacing:20) {
                
                versionNode
                
                netVersionNode
                
                peerCountNode
                
                balanceNode
                
                signAndSendTxNode
                
                checkSignAndSendTxHashNode
                
                readFromContractFunctionNode
                
                writeToContractFunctionNode
                
                checkWriteToContractFunctionNode
                
                Spacer()
                
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
