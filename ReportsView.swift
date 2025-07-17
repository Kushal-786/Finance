//
//  ReportsView.swift
//  FinanceApp
//
//  Created by Muthukutti P on 15/07/25.
//

import SwiftUI

struct ReportsView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @State private var selectedReportType: ReportData.ReportType = .income
    @State private var selectedPeriod: ReportPeriod = .thisMonth
    @State private var customStartDate = Date()
    @State private var customEndDate = Date()
    @State private var reportSummary: ReportSummary?
    @State private var isGenerating = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Back Button (if needed)
                    HStack {
                        Button(action: {}) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                        .opacity(0) // Hidden for now
                        
                        Spacer()
                    }
                    
                    // Generate Report Section
                    generateReportSection
                        .background(
                            Group {
                                if #available(iOS 18.0, *) {
                                    Color.clear    } else {
                                    Color(.systemBackground).opacity(0.7).background(.ultraThinMaterial)
                                }
                            }
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    
                    // Report Summary Section
                    if let summary = reportSummary {
                        reportSummarySection(summary: summary)
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
                    
                    // Report Actions
                    reportActionsSection
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
                    
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.horizontal)
                // Removed .background(.ultraThinMaterial) and .cornerRadius(24)
                // .background(.ultraThinMaterial)
                // .cornerRadius(24)
                // .padding(.horizontal, 8)
            }
            .background(Color.clear)
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("Reports")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            await generateReport()
        }
    }
    
    private var generateReportSection: some View {
        VStack(spacing: 20) {
            Text("Generate Report")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Report Type Selection
            VStack(spacing: 12) {
                HStack {
                    ReportTypeButton(
                        title: "Income",
                        isSelected: selectedReportType == .income,
                        action: { selectedReportType = .income }
                    )
                    
                    ReportTypeButton(
                        title: "Expenses",
                        isSelected: selectedReportType == .expenses,
                        action: { selectedReportType = .expenses }
                    )
                    
                    ReportTypeButton(
                        title: "Profit",
                        isSelected: selectedReportType == .profit,
                        action: { selectedReportType = .profit }
                    )
                }
            }
            
            // Period Selection
            VStack(spacing: 12) {
                HStack {
                    PeriodButton(
                        title: "This Month",
                        isSelected: selectedPeriod == .thisMonth,
                        action: { selectedPeriod = .thisMonth }
                    )
                    
                    PeriodButton(
                        title: "Last Month",
                        isSelected: selectedPeriod == .lastMonth,
                        action: { selectedPeriod = .lastMonth }
                    )
                    
                    PeriodButton(
                        title: "Custom",
                        isSelected: selectedPeriod == .custom,
                        action: { selectedPeriod = .custom }
                    )
                }
                
                // Custom Date Pickers (if custom period is selected)
                if selectedPeriod == .custom {
                    VStack(spacing: 8) {
                        DatePicker("Start Date", selection: $customStartDate, displayedComponents: .date)
                        DatePicker("End Date", selection: $customEndDate, displayedComponents: .date)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                }
            }
            
            // Generate Button
            Button(action: { Task { await generateReport() } }) {
                HStack {
                    if isGenerating {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    Text("Generate Report")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isGenerating)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private func reportSummarySection(summary: ReportSummary) -> some View {
        VStack(spacing: 20) {
            Text("Report Summary")
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                // Total Income Card
                SummaryCard(
                    title: "Total Income",
                    amount: summary.totalIncome,
                    color: .green
                )
                
                // Transactions Card
                VStack(alignment: .leading, spacing: 8) {
                    Text("Transactions")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("\(summary.transactionCount)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var reportActionsSection: some View {
        VStack(spacing: 16) {
            Button(action: {}) {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .frame(width: 24, height: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Income Report")
                            .font(.body)
                            .fontWeight(.medium)
                        
                        Text("View detailed income report")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            }
            .foregroundColor(.primary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    @MainActor
    private func generateReport() async {
        isGenerating = true
        
        // Simulate report generation
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        
        // Generate mock data based on selected criteria
        let totalIncome: Double
        let transactionCount: Int
        
        switch (selectedReportType, selectedPeriod) {
        case (.income, .thisMonth):
            totalIncome = 12500
            transactionCount = 35
        case (.income, .lastMonth):
            totalIncome = 9800
            transactionCount = 28
        case (.income, .custom):
            totalIncome = 15000
            transactionCount = 40
        case (.expenses, .thisMonth):
            totalIncome = 8200
            transactionCount = 42
        case (.expenses, .lastMonth):
            totalIncome = 7600
            transactionCount = 38
        case (.expenses, .custom):
            totalIncome = 9000
            transactionCount = 50
        case (.profit, .thisMonth):
            totalIncome = 4300
            transactionCount = 28
        case (.profit, .lastMonth):
            totalIncome = 2200
            transactionCount = 18
        case (.profit, .custom):
            totalIncome = 6000
            transactionCount = 32
        }
        
        reportSummary = ReportSummary(
            totalIncome: totalIncome,
            transactionCount: transactionCount
        )
        
        isGenerating = false
    }
}

// MARK: - Supporting Types

enum ReportPeriod {
    case thisMonth
    case lastMonth
    case custom
}

struct ReportSummary {
    let totalIncome: Double
    let transactionCount: Int
}

// MARK: - Supporting Views

struct ReportTypeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(isSelected ? Color.primary : Color(.systemGray6))
                .foregroundColor(isSelected ? Color(.systemBackground) : Color.primary)
                .cornerRadius(25)
        }
    }
}

struct PeriodButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .fontWeight(.medium)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(isSelected ? Color.primary : Color(.systemGray6))
                .foregroundColor(isSelected ? Color(.systemBackground) : Color.primary)
                .cornerRadius(25)
        }
    }
}

#Preview {
    ReportsView()
        .environmentObject(FirebaseService())
} 
