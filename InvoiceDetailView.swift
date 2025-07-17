//
//  InvoiceDetailView.swift
//  FinanceApp
//
//  Created by Kushal S on 10/07/25.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//

import SwiftUI

struct InvoiceDetailView: View {
    let invoice: Invoice
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 40))
                        VStack(alignment: .leading) {
                            Text(invoice.clientName)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(invoice.invoiceNumber)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        StatusBadge(status: invoice.status)
                    }
                    Divider()
                    HStack {
                        Text("Amount")
                            .font(.headline)
                        Spacer()
                        Text(invoice.amount.formatted(.currency(code: "USD")))
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    HStack {
                        Text("Date Created")
                            .font(.headline)
                        Spacer()
                        Text(invoice.dateCreated, style: .date)
                    }
                    HStack {
                        Text("Due Date")
                            .font(.headline)
                        Spacer()
                        Text(invoice.dueDate, style: .date)
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
        .navigationTitle("Invoice Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    InvoiceDetailView(invoice: Invoice(
        id: UUID().uuidString,
        clientName: "Orion Solutions",
        invoiceNumber: "#20201",
        amount: 950,
        dateCreated: Date(),
        dueDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date(),
        status: .pending
    ))
} 