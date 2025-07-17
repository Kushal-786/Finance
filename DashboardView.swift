//
//  DashboardView.swift
//  FinanceApp
//
//  Created by Muthukutti P on 15/07/25.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @State private var dashboardSummary: DashboardSummary?
    @State private var revenueChartData: [ChartDataPoint] = []
    @State private var expenseCategories: [ExpenseCategory] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if isLoading {
                        ProgressView("Loading...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        summaryCardsSection
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
                        
                        // Revenue Trend Chart
                        revenueTrendSection
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
                        
                        // Expense Breakdown
                        expenseBreakdownSection
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
                        
                        // Recent Activity
                        recentActivitySection
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
                }
                .padding(.top, 16)
                .padding(.horizontal)
                .safeAreaInset(edge: .bottom) {
                    Spacer().frame(height: 8)
                }
                .background(.ultraThinMaterial)
                .cornerRadius(24)
                .padding(.horizontal, 8)
            }
            .background(Color.clear)
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { 
                        Task { await loadData() } 
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .task {
            await loadData()
        }
    }
    
    private var summaryCardsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Total Revenue Card
                SummaryCard(
                    title: "Total Revenue",
                    amount: dashboardSummary?.totalRevenue ?? 0,
                    color: .blue
                )
                
                // Total Expenses Card
                SummaryCard(
                    title: "Total Expenses",
                    amount: dashboardSummary?.totalExpenses ?? 0,
                    color: .red
                )
            }
            
            // Net Profit Card (Full Width)
            SummaryCard(
                title: "Net Profit",
                amount: dashboardSummary?.netProfit ?? 0,
                color: .green,
                isWide: true
            )
        }
    }
    
    private var revenueTrendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Revenue Trend")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Text("+15%")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Spacer()
                    }
                    
                    Text("Last 12 Months +15%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Simple Line Chart
            if #available(iOS 16.0, *) {
                Chart(revenueChartData) { dataPoint in
                    LineMark(
                        x: .value("Month", dataPoint.month),
                        y: .value("Revenue", dataPoint.value)
                    )
                    .foregroundStyle(.blue)
                }
                .frame(height: 150)
                .chartYAxis(.hidden)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                // Fallback for iOS 15
                Rectangle()
                    .fill(.blue.opacity(0.3))
                    .frame(height: 150)
                    .overlay(
                        Text("Chart requires iOS 16+")
                            .foregroundColor(.secondary)
                    )
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
    
    private var expenseBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Expense Breakdown")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("-5%")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("This Year -5%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Simple Bar Chart
            if #available(iOS 16.0, *), !expenseCategories.isEmpty {
                Chart(expenseCategories.prefix(3)) { category in
                    BarMark(
                        x: .value("Category", category.name),
                        y: .value("Amount", category.amount)
                    )
                    .foregroundStyle(categoryColor(for: category.name))
                }
                .frame(height: 120)
                .chartYAxis(.hidden)
            } else {
                HStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { index in
                        VStack {
                            Rectangle()
                                .fill(.gray)
                                .frame(width: 40, height: CGFloat.random(in: 60...100))
                            
                            Text("Category \(index + 1)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(height: 120)
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
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Activity")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                // Recent Invoice
                ActivityRow(
                    icon: "doc.text.fill",
                    title: "Invoice Paid",
                    subtitle: "Invoice #1234",
                    iconColor: .blue
                )
                
                // Recent Expense
                ActivityRow(
                    icon: "dollarsign.circle.fill",
                    title: "Expense Submitted",
                    subtitle: "Expense Report",
                    iconColor: .orange
                )
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
    
    @MainActor
    private func loadData() async {
        isLoading = true
        
        do {
            // Load dashboard summary
            dashboardSummary = try await firebaseService.fetchDashboardSummary()
            
            // Load chart data
            revenueChartData = try await firebaseService.fetchRevenueChartData()
            
            // Load expense categories
            expenseCategories = try await firebaseService.fetchExpenseCategoryData()
            
        } catch {
            print("Error loading dashboard data: \(error)")
            // Set some default data for demo purposes
            dashboardSummary = DashboardSummary(
                totalRevenue: 120000,
                totalExpenses: 50000,
                netProfit: 70000,
                revenueGrowth: 15.0,
                expenseReduction: -5.0,
                recentInvoices: [],
                recentExpenses: []
            )
        }
        
        isLoading = false
    }
    
    private func categoryColor(for name: String) -> Color {
        switch name.lowercased() {
        case "office": return .blue
        case "travel": return .orange
        case "equipment": return .purple
        case "software": return .green
        case "business": return .pink
        default: return .gray
        }
    }
}

// MARK: - Supporting Views

struct SummaryCard: View {
    let title: String
    let amount: Double
    let color: Color
    var isWide: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(amount.formatted(.currency(code: "USD")))
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
        .frame(maxWidth: isWide ? .infinity : nil)
    }
}

struct ActivityRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    DashboardView()
        .environmentObject(FirebaseService())
} 
