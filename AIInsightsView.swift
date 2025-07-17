//
//  AIInsightsView.swift
//  FinanceApp
//
//  Created by Kushal S on 10/07/25.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.
//

import SwiftUI

struct AIInsightsView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @StateObject private var aiService = AIService()
    @State private var invoices: [Invoice] = []
    @State private var expenses: [Expense] = []
    @State private var financialInsights: FinancialInsights?
    @State private var isLoading = false
    @State private var selectedInsightType: InsightType = .overview
    
    enum InsightType: String, CaseIterable {
        case overview = "Overview"
        case expenses = "Expenses"
        case invoices = "Invoices"
        case recommendations = "Recommendations"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Insight Type Selector
                    insightTypeSelector
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
                    
                    if isLoading {
                        ProgressView("Analyzing your finances...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    } else if let insights = financialInsights {
                        switch selectedInsightType {
                        case .overview:
                            overviewSection(insights: insights)
                        case .expenses:
                            expenseAnalysisSection
                        case .invoices:
                            invoiceAnalysisSection
                        case .recommendations:
                            recommendationsSection(insights: insights)
                        }
                    } else {
                        generateInsightsButton
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
                    
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.horizontal)
                .safeAreaInset(edge: .bottom) {
                    Spacer().frame(height: 8)
                }
            }
            .background(Color.clear)
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("AI Insights")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            await loadData()
        }
    }
    
    // MARK: - Insight Type Selector
    private var insightTypeSelector: some View {
        HStack(spacing: 12) {
            ForEach(InsightType.allCases, id: \.self) { type in
                Button(action: { selectedInsightType = type }) {
                    Text(type.rawValue)
                        .font(.body)
                        .fontWeight(.medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            selectedInsightType == type ? 
                            Color.blue.opacity(0.2) : 
                            Color.clear
                        )
                        .foregroundColor(selectedInsightType == type ? .blue : .primary)
                        .cornerRadius(20)
                }
            }
        }
        .padding()
    }
    
    // MARK: - Generate Insights Button
    private var generateInsightsButton: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            Text("Generate AI Insights")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Get intelligent analysis of your financial data using Apple's Foundation Model")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: { Task { await generateInsights() } }) {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Analyze Finances")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding()
    }
    
    // MARK: - Overview Section
    private func overviewSection(insights: FinancialInsights) -> some View {
        VStack(spacing: 16) {
            Text("Financial Overview")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Cash Flow Trend
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cash Flow")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(insights.cashFlowTrend.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(cashFlowColor(insights.cashFlowTrend))
                }
                
                Spacer()
                
                Image(systemName: cashFlowIcon(insights.cashFlowTrend))
                    .font(.title)
                    .foregroundColor(cashFlowColor(insights.cashFlowTrend))
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
            .cornerRadius(12)
            
            // Risk Assessment
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Risk Level")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(insights.riskAssessment.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(riskColor(insights.riskAssessment))
                }
                
                Spacer()
                
                Image(systemName: riskIcon(insights.riskAssessment))
                    .font(.title)
                    .foregroundColor(riskColor(insights.riskAssessment))
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
            .cornerRadius(12)
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
    
    // MARK: - Expense Analysis Section
    private var expenseAnalysisSection: some View {
        VStack(spacing: 16) {
            Text("Expense Analysis")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(expenses.prefix(3), id: \.id) { expense in
                ExpenseInsightRow(expense: expense, aiService: aiService)
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
    
    // MARK: - Invoice Analysis Section
    private var invoiceAnalysisSection: some View {
        VStack(spacing: 16) {
            Text("Invoice Analysis")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(invoices.prefix(3), id: \.id) { invoice in
                InvoiceInsightRow(invoice: invoice, aiService: aiService)
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
    
    // MARK: - Recommendations Section
    private func recommendationsSection(insights: FinancialInsights) -> some View {
        VStack(spacing: 16) {
            Text("AI Recommendations")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                ForEach(insights.recommendations, id: \.self) { recommendation in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                            .frame(width: 20)
                        
                        Text(recommendation)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
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
    
    // MARK: - Helper Functions
    private func cashFlowColor(_ trend: CashFlowTrend) -> Color {
        switch trend {
        case .positive: return .green
        case .stable: return .orange
        case .negative: return .red
        }
    }
    
    private func cashFlowIcon(_ trend: CashFlowTrend) -> String {
        switch trend {
        case .positive: return "arrow.up.circle.fill"
        case .stable: return "minus.circle.fill"
        case .negative: return "arrow.down.circle.fill"
        }
    }
    
    private func riskColor(_ risk: RiskAssessment) -> Color {
        switch risk {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
    
    private func riskIcon(_ risk: RiskAssessment) -> String {
        switch risk {
        case .low: return "checkmark.shield.fill"
        case .medium: return "exclamationmark.triangle.fill"
        case .high: return "xmark.shield.fill"
        }
    }
    
    // MARK: - Data Loading
    @MainActor
    private func loadData() async {
        // Load sample data for demo
        invoices = [
            Invoice(
                id: UUID().uuidString,
                clientName: "Orion Solutions",
                invoiceNumber: "#20201",
                amount: 950,
                dateCreated: Date(),
                dueDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date(),
                status: .pending
            ),
            Invoice(
                id: UUID().uuidString,
                clientName: "Nimbus Tech",
                invoiceNumber: "#20202",
                amount: 1200,
                dateCreated: Date(),
                dueDate: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
                status: .overdue
            )
        ]
        
        expenses = [
            Expense(
                id: UUID().uuidString,
                title: "Office Supplies",
                amount: 25.00,
                category: "Office",
                dateCreated: Date(),
                description: "Pens, paper, notebooks"
            ),
            Expense(
                id: UUID().uuidString,
                title: "Travel",
                amount: 150.00,
                category: "Travel",
                dateCreated: Date(),
                description: "Flight to conference"
            )
        ]
    }
    
    @MainActor
    private func generateInsights() async {
        isLoading = true
        financialInsights = await aiService.generateFinancialInsights(invoices: invoices, expenses: expenses)
        isLoading = false
    }
}

// MARK: - Supporting Views
struct ExpenseInsightRow: View {
    let expense: Expense
    let aiService: AIService
    @State private var analysis: ExpenseAnalysis?
    @State private var isLoading = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(expense.title)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text(expense.amount.formatted(.currency(code: "USD")))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if let analysis = analysis {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(analysis.riskLevel.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(riskColor(analysis.riskLevel).opacity(0.2))
                            .foregroundColor(riskColor(analysis.riskLevel))
                            .cornerRadius(4)
                        
                        if analysis.suggestedCategory != expense.category {
                            Text("→ \(analysis.suggestedCategory)")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            
            if let analysis = analysis, !analysis.insights.isEmpty {
                Text(analysis.insights.first ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
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
        .cornerRadius(12)
        .onAppear {
            Task {
                isLoading = true
                analysis = await aiService.analyzeExpense(expense)
                isLoading = false
            }
        }
    }
    
    private func riskColor(_ risk: RiskLevel) -> Color {
        switch risk {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

struct InvoiceInsightRow: View {
    let invoice: Invoice
    let aiService: AIService
    @State private var analysis: InvoiceAnalysis?
    @State private var isLoading = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(invoice.clientName)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text(invoice.amount.formatted(.currency(code: "USD")))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if let analysis = analysis {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(analysis.paymentPrediction.rawValue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(paymentColor(analysis.paymentPrediction).opacity(0.2))
                            .foregroundColor(paymentColor(analysis.paymentPrediction))
                            .cornerRadius(4)
                        
                        Text(analysis.clientRisk.rawValue)
                            .font(.caption)
                            .foregroundColor(riskColor(analysis.clientRisk))
                    }
                }
            }
            
            if let analysis = analysis, !analysis.insights.isEmpty {
                Text(analysis.insights.first ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
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
        .cornerRadius(12)
        .onAppear {
            Task {
                isLoading = true
                analysis = await aiService.analyzeInvoice(invoice)
                isLoading = false
            }
        }
    }
    
    private func paymentColor(_ prediction: PaymentPrediction) -> Color {
        switch prediction {
        case .likely: return .green
        case .possible: return .orange
        case .uncertain: return .yellow
        case .overdue: return .red
        }
    }
    
    private func riskColor(_ risk: ClientRisk) -> Color {
        switch risk {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

#Preview {
    AIInsightsView()
        .environmentObject(FirebaseService())
} 
