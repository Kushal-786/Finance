//
//  ExpenseDetailView.swift
//  FinanceApp
//
//  Created by Kushal S on 10/07/25.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//

import SwiftUI

struct ExpenseDetailView: View {
    let expense: Expense
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.orange)
                            .font(.system(size: 40))
                        VStack(alignment: .leading) {
                            Text(expense.title)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(expense.category)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    Divider()
                    HStack {
                        Text("Amount")
                            .font(.headline)
                        Spacer()
                        Text(expense.amount.formatted(.currency(code: "USD")))
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    HStack {
                        Text("Date Created")
                            .font(.headline)
                        Spacer()
                        Text(expense.dateCreated, style: .date)
                    }
                    if let desc = expense.description, !desc.isEmpty {
                        Divider()
                        Text("Description")
                            .font(.headline)
                        Text(desc)
                            .font(.body)
                            .foregroundColor(.secondary)
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
        .navigationTitle("Expense Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ExpenseDetailView(expense: Expense(
        id: UUID().uuidString,
        title: "Travel",
        amount: 150.00,
        category: "Travel",
        dateCreated: Date(),
        description: "Flight to conference"
    ))
} 