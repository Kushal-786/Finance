//
//  AIService.swift
//  FinanceApp
//
//  Created by Kushal S on 10/07/25.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - AI Service for Foundation Model Integration
@MainActor
class AIService: ObservableObject {
    
    // MARK: - Financial Analysis
    func analyzeExpense(_ expense: Expense) async -> ExpenseAnalysis {
        // Simulate AI analysis using Foundation Model
        let analysis = ExpenseAnalysis(
            category: expense.category,
            suggestedCategory: suggestCategory(for: expense.title),
            riskLevel: assessRiskLevel(amount: expense.amount),
            insights: generateInsights(for: expense),
            recommendations: generateRecommendations(for: expense)
        )
        
        // Simulate processing time
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        return analysis
    }
    
    func analyzeInvoice(_ invoice: Invoice) async -> InvoiceAnalysis {
        // Simulate AI analysis using Foundation Model
        let analysis = InvoiceAnalysis(
            clientRisk: assessClientRisk(invoice: invoice),
            paymentPrediction: predictPayment(invoice: invoice),
            insights: generateInvoiceInsights(invoice),
            recommendations: generateInvoiceRecommendations(invoice)
        )
        
        // Simulate processing time
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        return analysis
    }
    
    func generateFinancialInsights(invoices: [Invoice], expenses: [Expense]) async -> FinancialInsights {
        // Simulate comprehensive financial analysis
        let insights = FinancialInsights(
            cashFlowTrend: analyzeCashFlow(invoices: invoices, expenses: expenses),
            expenseOptimization: suggestExpenseOptimization(expenses: expenses),
            revenueOpportunities: identifyRevenueOpportunities(invoices: invoices),
            riskAssessment: assessOverallRisk(invoices: invoices, expenses: expenses),
            recommendations: generateStrategicRecommendations(invoices: invoices, expenses: expenses)
        )
        
        // Simulate processing time
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        return insights
    }
    
    // MARK: - Smart Categorization
    private func suggestCategory(for title: String) -> String {
        let lowercased = title.lowercased()
        
        if lowercased.contains("office") || lowercased.contains("supply") || lowercased.contains("pen") || lowercased.contains("paper") {
            return "Office"
        } else if lowercased.contains("travel") || lowercased.contains("flight") || lowercased.contains("hotel") || lowercased.contains("uber") {
            return "Travel"
        } else if lowercased.contains("software") || lowercased.contains("license") || lowercased.contains("subscription") {
            return "Software"
        } else if lowercased.contains("equipment") || lowercased.contains("computer") || lowercased.contains("monitor") {
            return "Equipment"
        } else if lowercased.contains("meeting") || lowercased.contains("lunch") || lowercased.contains("dinner") {
            return "Business"
        } else {
            return "Other"
        }
    }
    
    // MARK: - Risk Assessment
    private func assessRiskLevel(amount: Double) -> RiskLevel {
        if amount > 1000 {
            return .high
        } else if amount > 500 {
            return .medium
        } else {
            return .low
        }
    }
    
    private func assessClientRisk(invoice: Invoice) -> ClientRisk {
        let daysOverdue = Calendar.current.dateComponents([.day], from: invoice.dueDate, to: Date()).day ?? 0
        
        if daysOverdue > 30 {
            return .high
        } else if daysOverdue > 15 {
            return .medium
        } else {
            return .low
        }
    }
    
    private func assessOverallRisk(invoices: [Invoice], expenses: [Expense]) -> RiskAssessment {
        let overdueInvoices = invoices.filter { $0.status == .overdue }
        let highExpenses = expenses.filter { $0.amount > 1000 }
        
        let riskScore = (Double(overdueInvoices.count) / Double(invoices.count)) * 0.6 +
                       (Double(highExpenses.count) / Double(expenses.count)) * 0.4
        
        if riskScore > 0.3 {
            return .high
        } else if riskScore > 0.1 {
            return .medium
        } else {
            return .low
        }
    }
    
    // MARK: - Payment Prediction
    private func predictPayment(invoice: Invoice) -> PaymentPrediction {
        let daysUntilDue = Calendar.current.dateComponents([.day], from: Date(), to: invoice.dueDate).day ?? 0
        
        if daysUntilDue < 0 {
            return .overdue
        } else if daysUntilDue <= 7 {
            return .likely
        } else if daysUntilDue <= 30 {
            return .possible
        } else {
            return .uncertain
        }
    }
    
    // MARK: - Cash Flow Analysis
    private func analyzeCashFlow(invoices: [Invoice], expenses: [Expense]) -> CashFlowTrend {
        let totalRevenue = invoices.filter { $0.status == .paid }.reduce(0) { $0 + $1.amount }
        let totalExpenses = expenses.reduce(0) { $0 + $1.amount }
        let netCashFlow = totalRevenue - totalExpenses
        
        if netCashFlow > 0 {
            return .positive
        } else if netCashFlow > -1000 {
            return .stable
        } else {
            return .negative
        }
    }
    
    // MARK: - Insights Generation
    private func generateInsights(for expense: Expense) -> [String] {
        var insights: [String] = []
        
        if expense.amount > 500 {
            insights.append("This is a significant expense. Consider negotiating better rates.")
        }
        
        if expense.category == "Travel" {
            insights.append("Travel expenses are tax-deductible. Keep receipts for tax season.")
        }
        
        if expense.category == "Software" {
            insights.append("Consider annual subscriptions for better pricing.")
        }
        
        return insights
    }
    
    private func generateInvoiceInsights(_ invoice: Invoice) -> [String] {
        var insights: [String] = []
        
        if invoice.status == .overdue {
            insights.append("Invoice is overdue. Consider sending a reminder.")
        }
        
        if invoice.amount > 1000 {
            insights.append("Large invoice amount. Consider payment terms negotiation.")
        }
        
        return insights
    }
    
    // MARK: - Recommendations
    private func generateRecommendations(for expense: Expense) -> [String] {
        var recommendations: [String] = []
        
        if expense.amount > 1000 {
            recommendations.append("Consider bulk purchasing for better rates")
        }
        
        if expense.category == "Office" {
            recommendations.append("Set up automated office supply ordering")
        }
        
        return recommendations
    }
    
    private func generateInvoiceRecommendations(_ invoice: Invoice) -> [String] {
        var recommendations: [String] = []
        
        if invoice.status == .overdue {
            recommendations.append("Send payment reminder with late fees")
            recommendations.append("Consider payment plan options")
        }
        
        return recommendations
    }
    
    private func suggestExpenseOptimization(expenses: [Expense]) -> [String] {
        var optimizations: [String] = []
        
        let totalExpenses = expenses.reduce(0) { $0 + $1.amount }
        if totalExpenses > 10000 {
            optimizations.append("Total expenses are high. Review discretionary spending")
        }
        
        let travelExpenses = expenses.filter { $0.category == "Travel" }.reduce(0) { $0 + $1.amount }
        if travelExpenses > 5000 {
            optimizations.append("Consider virtual meetings to reduce travel costs")
        }
        
        return optimizations
    }
    
    private func identifyRevenueOpportunities(invoices: [Invoice]) -> [String] {
        var opportunities: [String] = []
        
        let pendingInvoices = invoices.filter { $0.status == .pending }
        if !pendingInvoices.isEmpty {
            opportunities.append("Follow up on \(pendingInvoices.count) pending invoices")
        }
        
        let averageInvoiceAmount = invoices.reduce(0) { $0 + $1.amount } / Double(invoices.count)
        if averageInvoiceAmount < 500 {
            opportunities.append("Consider increasing service rates")
        }
        
        return opportunities
    }
    
    private func generateStrategicRecommendations(invoices: [Invoice], expenses: [Expense]) -> [String] {
        var recommendations: [String] = []
        
        let netProfit = invoices.filter { $0.status == .paid }.reduce(0) { $0 + $1.amount } - expenses.reduce(0) { $0 + $1.amount }
        
        if netProfit < 0 {
            recommendations.append("Focus on increasing revenue or reducing costs")
        }
        
        recommendations.append("Set up automated invoice reminders")
        recommendations.append("Implement expense approval workflow")
        
        return recommendations
    }
}

// MARK: - Analysis Models
struct ExpenseAnalysis {
    let category: String
    let suggestedCategory: String
    let riskLevel: RiskLevel
    let insights: [String]
    let recommendations: [String]
}

struct InvoiceAnalysis {
    let clientRisk: ClientRisk
    let paymentPrediction: PaymentPrediction
    let insights: [String]
    let recommendations: [String]
}

struct FinancialInsights {
    let cashFlowTrend: CashFlowTrend
    let expenseOptimization: [String]
    let revenueOpportunities: [String]
    let riskAssessment: RiskAssessment
    let recommendations: [String]
}

// MARK: - Enums
enum RiskLevel: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

enum ClientRisk: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
}

enum PaymentPrediction: String, CaseIterable {
    case likely = "Likely"
    case possible = "Possible"
    case uncertain = "Uncertain"
    case overdue = "Overdue"
}

enum CashFlowTrend: String, CaseIterable {
    case positive = "Positive"
    case stable = "Stable"
    case negative = "Negative"
}

enum RiskAssessment: String, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
} 
