//
//  ClientDetailView.swift
//  FinanceApp
//
//  Created by Kushal S on 10/07/25.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//

import SwiftUI

struct ClientDetailView: View {
    let client: Client
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .foregroundColor(.purple)
                            .font(.system(size: 40))
                        VStack(alignment: .leading) {
                            Text(client.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            if let company = client.company {
                                Text(company)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                    }
                    Divider()
                    HStack {
                        Text("Email")
                            .font(.headline)
                        Spacer()
                        Text(client.email)
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                    HStack {
                        Text("Phone")
                            .font(.headline)
                        Spacer()
                        Text(client.phone)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    if let address = client.address, !address.isEmpty {
                        Divider()
                        Text("Address")
                            .font(.headline)
                        Text(address)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Date Added")
                            .font(.headline)
                        Spacer()
                        Text(client.dateAdded, style: .date)
                    }
                }
                .padding()
                .background(
                    Group {
                        if #available(iOS 18.0, *) {
                            Color.clear
                        } else {
                            Color(.systemBackground).opacity(0.7).background(.ultraThinMaterial)
                        }
                    }
                )
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            }
            .padding()
        }
        .navigationTitle("Client Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ClientDetailView(client: Client(
        id: UUID().uuidString,
        name: "Acme Corp",
        email: "contact@acmecorp.com",
        phone: "+1 (555) 123-4567",
        address: "123 Business St, City, State 12345",
        company: "Acme Corporation",
        dateAdded: Date()
    ))
} 