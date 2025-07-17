//
//  InvoicesView.swift
//  FinanceApp
//
//  Created by Muthukutti P on 15/07/25.
//

import SwiftUI

struct InvoicesView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @State private var invoices: [Invoice] = []
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var showingAddInvoice = false
    
    var filteredInvoices: [Invoice] {
        if searchText.isEmpty {
            return invoices
        } else {
            return invoices.filter { invoice in
                invoice.clientName.localizedCaseInsensitiveContains(searchText) ||
                invoice.invoiceNumber.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                
                if isLoading {
                    ProgressView("Loading invoices...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredInvoices.isEmpty {
                    EmptyStateView(
                        icon: "doc.text",
                        title: "No Invoices",
                        subtitle: searchText.isEmpty ? "Add your first invoice" : "No invoices match your search"
                    )
                } else {
                    // Invoice List
                    List {
                        ForEach(filteredInvoices) { invoice in
                            NavigationLink(destination: InvoiceDetailView(invoice: invoice)) {
                                InvoiceRow(invoice: invoice)
                            }
                            .swipeActions(edge: .trailing) {
                                Button("Delete", role: .destructive) {
                                    deleteInvoice(invoice)
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                
                Spacer()
            }
            .navigationTitle("Invoices")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddInvoice = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddInvoice) {
                AddInvoiceView { newInvoice in
                    addInvoice(newInvoice)
                }
            }
        }
        .task {
            await loadInvoices()
        }
    }
    
    @MainActor
    private func loadInvoices() async {
        isLoading = true
        
        // For demo purposes, always use sample data
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
                dueDate: Calendar.current.date(byAdding: .day, value: 25, to: Date()) ?? Date(),
                status: .paid
            ),
            Invoice(
                id: UUID().uuidString,
                clientName: "Vertex Dynamics",
                invoiceNumber: "#20203",
                amount: 675,
                dateCreated: Date(),
                dueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(),
                status: .overdue
            ),
            Invoice(
                id: UUID().uuidString,
                clientName: "Helix Industries",
                invoiceNumber: "#20204",
                amount: 430,
                dateCreated: Date(),
                dueDate: Calendar.current.date(byAdding: .day, value: 18, to: Date()) ?? Date(),
                status: .pending
            )
        ]
        
        isLoading = false
    }
    
    private func addInvoice(_ invoice: Invoice) {
        invoices.insert(invoice, at: 0) // Always insert immediately for instant UI update
        Task {
            do {
                try await firebaseService.addInvoice(invoice)
                // Do not reload from Firebase/sample data after adding
            } catch {
                print("Error adding invoice: \(error)")
                // Already inserted for demo, so no further action needed
            }
        }
    }
    
    private func deleteInvoice(_ invoice: Invoice) {
        Task {
            do {
                try await firebaseService.deleteInvoice(invoice)
                await loadInvoices()
            } catch {
                print("Error deleting invoice: \(error)")
                // For demo purposes, remove from local array
                invoices.removeAll { $0.id == invoice.id }
            }
        }
    }
}

// MARK: - Supporting Views

struct InvoiceRow: View {
    let invoice: Invoice
    
    var body: some View {
        Group {
            if #available(iOS 18.0, *) {
                HStack {
                    // Invoice Icon
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.blue)
                        .frame(width: 40, height: 40)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(invoice.clientName)
                            .font(.headline)
                            .fontWeight(.medium)
                        Text(invoice.invoiceNumber)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(invoice.amount.formatted(.currency(code: "USD")))
                            .font(.headline)
                            .fontWeight(.semibold)
                        StatusBadge(status: invoice.status)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 8)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            } else {
                HStack {
                    // Invoice Icon
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.blue)
                        .frame(width: 40, height: 40)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(invoice.clientName)
                            .font(.headline)
                            .fontWeight(.medium)
                        Text(invoice.invoiceNumber)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(invoice.amount.formatted(.currency(code: "USD")))
                            .font(.headline)
                            .fontWeight(.semibold)
                        StatusBadge(status: invoice.status)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 8)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                .background(.ultraThinMaterial)
            }
        }
    }
}

struct StatusBadge: View {
    let status: Invoice.InvoiceStatus
    
    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .cornerRadius(4)
    }
    
    private var backgroundColor: Color {
        switch status {
        case .paid:
            return .green.opacity(0.2)
        case .pending:
            return .orange.opacity(0.2)
        case .overdue:
            return .red.opacity(0.2)
        }
    }
    
    private var textColor: Color {
        switch status {
        case .paid:
            return .green
        case .pending:
            return .orange
        case .overdue:
            return .red
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text(subtitle)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AddInvoiceView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (Invoice) -> Void
    
    @State private var clientName = ""
    @State private var invoiceNumber = ""
    @State private var amount = ""
    @State private var dueDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Invoice Details") {
                    TextField("Client Name", text: $clientName)
                    TextField("Invoice Number", text: $invoiceNumber)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                }
            }
            .navigationTitle("New Invoice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveInvoice()
                    }
                    .disabled(clientName.isEmpty || invoiceNumber.isEmpty || amount.isEmpty)
                }
            }
        }
    }
    
    private func saveInvoice() {
        guard let amountValue = Double(amount) else { return }
        
        let invoice = Invoice(
            clientName: clientName,
            invoiceNumber: invoiceNumber,
            amount: amountValue,
            dateCreated: Date(),
            dueDate: dueDate,
            status: .pending
        )
        
        onSave(invoice)
        dismiss()
    }
}

#Preview {
    InvoicesView()
        .environmentObject(FirebaseService())
} 
