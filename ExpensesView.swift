//
//  ExpensesView.swift
//  FinanceApp
//
//  Created by Muthukutti P on 15/07/25.
//

import SwiftUI

struct ExpensesView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @State private var expenses: [Expense] = []
    @State private var searchText = ""
    @State private var isLoading = false
    @State private var showingAddExpense = false
    
    var filteredExpenses: [Expense] {
        if searchText.isEmpty {
            return expenses
        } else {
            return expenses.filter { expense in
                expense.title.localizedCaseInsensitiveContains(searchText) ||
                expense.category.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                SearchBarWithPlaceholder(text: $searchText, placeholder: "Search expenses")
                    .padding(.horizontal)
                
                if isLoading {
                    ProgressView("Loading expenses...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredExpenses.isEmpty {
                    EmptyStateView(
                        icon: "dollarsign.circle",
                        title: "No Expenses",
                        subtitle: searchText.isEmpty ? "Add your first expense" : "No expenses match your search"
                    )
                } else {
                    // Recent Expenses Header
                    HStack {
                        Text("Recent Expenses")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        Spacer()
                    }
                    
                    // Expense List
                    List {
                        ForEach(filteredExpenses) { expense in
                            NavigationLink(destination: ExpenseDetailView(expense: expense)) {
                                ExpenseRow(expense: expense)
                            }
                            .swipeActions(edge: .trailing) {
                                Button("Delete", role: .destructive) {
                                    deleteExpense(expense)
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                
                Spacer()
            }
            .navigationTitle("Expenses")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddExpense = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView { newExpense in
                    addExpense(newExpense)
                }
            }
        }
        .task {
            await loadExpenses()
        }
    }
    
    @MainActor
    private func loadExpenses() async {
        isLoading = true
        
        // For demo purposes, always use sample data
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
                title: "Client Meeting",
                amount: 75.00,
                category: "Business",
                dateCreated: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                description: "Lunch with client at Italian restaurant"
            ),
            Expense(
                id: UUID().uuidString,
                title: "Travel",
                amount: 150.00,
                category: "Travel",
                dateCreated: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
                description: "Flight to conference"
            ),
            Expense(
                id: UUID().uuidString,
                title: "Software License",
                amount: 89.99,
                category: "Software",
                dateCreated: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                description: "Annual subscription renewal"
            ),
            Expense(
                id: UUID().uuidString,
                title: "Equipment",
                amount: 299.99,
                category: "Equipment",
                dateCreated: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(),
                description: "New monitor for office"
            ),
            Expense(
                id: UUID().uuidString,
                title: "Lunch",
                amount: 18.50,
                category: "Food",
                dateCreated: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
                description: "Sandwich and coffee at local cafe"
            ),
            Expense(
                id: UUID().uuidString,
                title: "Clothing",
                amount: 60.00,
                category: "Clothing",
                dateCreated: Calendar.current.date(byAdding: .day, value: -6, to: Date()) ?? Date(),
                description: "Business casual shirt for meeting"
            )
        ]
        
        isLoading = false
    }
    
    private func addExpense(_ expense: Expense) {
        var expenseWithId = expense
        if expenseWithId.id == nil { expenseWithId.id = UUID().uuidString }
        expenses.insert(expenseWithId, at: 0) // Always insert immediately for instant UI update
        Task {
            do {
                try await firebaseService.addExpense(expenseWithId)
                // Do not reload from Firebase/sample data after adding
            } catch {
                print("Error adding expense: \(error)")
                // Already inserted for demo, so no further action needed
            }
        }
    }
    
    private func deleteExpense(_ expense: Expense) {
        Task {
            do {
                try await firebaseService.deleteExpense(expense)
                await loadExpenses()
            } catch {
                print("Error deleting expense: \(error)")
                // For demo purposes, remove from local array
                expenses.removeAll { $0.id == expense.id }
            }
        }
    }
}

// MARK: - Supporting Views

struct ExpenseRow: View {
    let expense: Expense
    
    var body: some View {
        Group {
            if #available(iOS 18.0, *) {
                HStack {
                    // Expense Icon
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.orange)
                        .frame(width: 40, height: 40)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(expense.amount.formatted(.currency(code: "USD")))
                            .font(.headline)
                            .fontWeight(.semibold)
                        Text(expense.title)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 8)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            } else {
                HStack {
                    // Expense Icon
                    Image(systemName: "doc.text.fill")
                        .foregroundColor(.orange)
                        .frame(width: 40, height: 40)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(expense.amount.formatted(.currency(code: "USD")))
                            .font(.headline)
                            .fontWeight(.semibold)
                        Text(expense.title)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
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

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (Expense) -> Void
    
    @State private var title = ""
    @State private var amount = ""
    @State private var category = "Office"
    @State private var description = ""
    
    let categories = ["Office", "Business", "Travel", "Equipment", "Software", "Other"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Expense Details") {
                    TextField("Title", text: $title)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    
                    TextField("Description (Optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("New Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveExpense()
                    }
                    .disabled(title.isEmpty || amount.isEmpty)
                }
            }
        }
    }
    
    private func saveExpense() {
        guard let amountValue = Double(amount) else { return }
        
        let expense = Expense(
            title: title,
            amount: amountValue,
            category: category,
            dateCreated: Date(),
            description: description.isEmpty ? nil : description
        )
        
        onSave(expense)
        dismiss()
    }
}

struct SearchBarWithPlaceholder: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    ExpensesView()
        .environmentObject(FirebaseService())
} 
