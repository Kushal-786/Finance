//
//  Models.swift
//  FinanceApp
//
//  Created by Muthukutti P on 15/07/25.
//

import Foundation
// TODO: Add back Firebase when properly configured
// import FirebaseFirestore

// MARK: - Invoice Model
struct Invoice: Identifiable, Codable {
    // TODO: Add back @DocumentID when Firebase is configured
    // @DocumentID var id: String?
    var id: String?
    var clientName: String
    var invoiceNumber: String
    var amount: Double
    var dateCreated: Date
    var dueDate: Date
    var status: InvoiceStatus
    var clientId: String?
    
    enum InvoiceStatus: String, CaseIterable, Codable {
        case pending = "pending"
        case paid = "paid"
        case overdue = "overdue"
    }
}

// MARK: - Expense Model
struct Expense: Identifiable, Codable {
    // TODO: Add back @DocumentID when Firebase is configured
    // @DocumentID var id: String?
    var id: String?
    var title: String
    var amount: Double
    var category: String
    var dateCreated: Date
    var description: String?
    var receiptURL: String?
}

// MARK: - Client Model
struct Client: Identifiable, Codable {
    // TODO: Add back @DocumentID when Firebase is configured
    // @DocumentID var id: String?
    var id: String?
    var name: String
    var email: String
    var phone: String
    var address: String?
    var company: String?
    var dateAdded: Date
}

// MARK: - Report Data Model
struct ReportData: Identifiable, Codable {
    // TODO: Add back @DocumentID when Firebase is configured
    // @DocumentID var id: String?
    var id: String?
    var reportType: ReportType
    var startDate: Date
    var endDate: Date
    var totalIncome: Double
    var totalExpenses: Double
    var netProfit: Double
    var transactionCount: Int
    var generatedDate: Date
    
    enum ReportType: String, CaseIterable, Codable {
        case income = "income"
        case expenses = "expenses"
        case profit = "profit"
    }
}

// MARK: - Dashboard Summary Model
struct DashboardSummary {
    var totalRevenue: Double
    var totalExpenses: Double
    var netProfit: Double
    var revenueGrowth: Double
    var expenseReduction: Double
    var recentInvoices: [Invoice]
    var recentExpenses: [Expense]
}

// MARK: - Chart Data Models
struct ChartDataPoint: Identifiable {
    let id = UUID()
    let month: String
    let value: Double
}

struct ExpenseCategory: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let percentage: Double
} 