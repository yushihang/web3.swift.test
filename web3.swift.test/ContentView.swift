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
    @State var version = ""
    
    @State var netVersion = ""
    
    @State var peerCount: Int64 = -1
    
    @State var txhash = ""
    
    @State var readContractFunctionResult = ""
    
    
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
    
    var signAndSendTxNode: some View {
        Group{
            Button {
                Task{
                    txhash = await viewModel.signAndSendTx(amount: 12345, toHex: "0xC0B05B621Ab20123bfC52186708444c783351e69") ?? "Error"
                }
            } label: {
                Text("Sign & Send Tx")
            }
            
            Text("tx hash: \(txhash)")
        }
    }
    
    
    var readFromContractFunctionNode: some View {
        Group{
            Button {
                Task{
                    txhash = await viewModel.readFromContractFunction() ?? "Error"
                }
            } label: {
                Text("Read Data from Contract Functions")
            }
            
            Text("result: \(readContractFunctionResult)")
        }
    }
    var body: some View {
        VStack(spacing:20) {
        
            versionNode
            
            netVersionNode
            
            peerCountNode
            
            signAndSendTxNode
            
            readFromContractFunctionNode
            
            Spacer()

        }
        .padding()
    }
}

#Preview {
    ContentView()
}
