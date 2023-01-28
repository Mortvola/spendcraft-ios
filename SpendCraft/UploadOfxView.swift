//
//  UploadOFX.swift
//  SpendCraft
//
//  Created by Richard Shields on 1/27/23.
//

import SwiftUI
import Framework

struct UploadOfxView: View {
    @ObservedObject var accountsStore = AccountsStore.shared

    var file: URL
    @Binding var show: Bool
    
    var filename: String {
        let name = file.lastPathComponent;

        if let name = name.removingPercentEncoding {
            return name
        }
        
        return name
    }

    var body: some View {
        VStack {
            Text("Uploading OFX file \"\(filename)\".")
                .padding(.bottom, 16)
            Text("Select the account to which you would like to upload the OFX file.")
            if (accountsStore.loading) {
                List {
                    ProgressView()
                }
            }
            else {
                List(accountsStore.accounts) { institute in
                    Text(institute.name)
                    ForEach(institute.accounts) { acct in
                        Button {
                            Task {
                                Busy.shared.busy = true
                                let result = await acct.uploadOfx(file: file)
                                
                                if let result = result, result.hasErrors() {
                                    result.printErrors()
                                } else {
                                    show = false
                                }

                                Busy.shared.busy = false
                            }
                        } label: {
                            Text(acct.name)
                        }
                        .padding(.leading)
                    }
                }
            }
        }
        .padding()
        .withBusyIndicator()
        .task {
            await accountsStore.load(force: true)
        }
    }
}

struct UploadOfxView_Previews: PreviewProvider {
    static var previews: some View {
        UploadOfxView(file: URL(fileURLWithPath: "Test"), show: .constant(true))
    }
}
