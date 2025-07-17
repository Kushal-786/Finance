//
//  ContentView.swift
//  FinanceApp
//
//  Created by Muthukutti P on 15/07/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var firebaseService = FirebaseService()
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
            
            InvoicesView()
                .tabItem {
                    Image(systemName: "doc.text.fill")
                    Text("Invoices")
                }
            
            ExpensesView()
                .tabItem {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("Expenses")
                }
            
            ClientsView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Clients")
                }
            
            ReportsView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Reports")
                }
            
            AIInsightsView()
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("AI Insights")
                }
        }
        .environmentObject(firebaseService)
        .background(.ultraThinMaterial)
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
