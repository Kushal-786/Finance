//
//  ClientsView.swift
//  FinanceApp
//
//  Created by Muthukutti P on 15/07/25.
//

import SwiftUI

struct ClientsView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @State private var clients: [Client] = []
    @State private var isLoading = false
    @State private var showingAddClient = false
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading clients...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if clients.isEmpty {
                    EmptyStateView(
                        icon: "person.2",
                        title: "No Clients",
                        subtitle: "Add your first client"
                    )
                } else {
                    // Client List
                    List {
                        ForEach(clients) { client in
                            NavigationLink(destination: ClientDetailView(client: client)) {
                                ClientRow(client: client)
                            }
                            .swipeActions(edge: .trailing) {
                                Button("Delete", role: .destructive) {
                                    deleteClient(client)
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                
                Spacer()
            }
            .navigationTitle("Clients")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddClient = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddClient) {
                AddClientView { newClient in
                    addClient(newClient)
                }
            }
        }
        .task {
            await loadClients()
        }
    }
    
    @MainActor
    private func loadClients() async {
        isLoading = true
        
        // For demo purposes, always use sample data
        clients = [
            Client(
                id: UUID().uuidString,
                name: "Acme Corp",
                email: "contact@acmecorp.com",
                phone: "+1 (555) 123-4567",
                address: "123 Business St, City, State 12345",
                company: "Acme Corporation",
                dateAdded: Date()
            ),
            Client(
                id: UUID().uuidString,
                name: "Tech Solutions Inc.",
                email: "info@techsolutions.com",
                phone: "+1 (555) 987-6543",
                address: "456 Tech Ave, Innovation City, State 67890",
                company: "Tech Solutions Inc.",
                dateAdded: Calendar.current.date(byAdding: .day, value: -5, to: Date()) ?? Date()
            ),
            Client(
                id: UUID().uuidString,
                name: "Global Enterprises",
                email: "contact@globalent.com",
                phone: "+1 (555) 246-8013",
                address: "789 Global Blvd, Metro City, State 54321",
                company: "Global Enterprises LLC",
                dateAdded: Calendar.current.date(byAdding: .day, value: -10, to: Date()) ?? Date()
            ),
            Client(
                id: UUID().uuidString,
                name: "Innovative Designs",
                email: "hello@innovativedesigns.com",
                phone: "+1 (555) 135-7911",
                address: "321 Creative St, Design District, State 98765",
                company: "Innovative Designs Studio",
                dateAdded: Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date()
            ),
            Client(
                id: UUID().uuidString,
                name: "Strategic Partners LLC",
                email: "partners@strategic.com",
                phone: "+1 (555) 369-2580",
                address: "654 Strategy Lane, Business Park, State 13579",
                company: "Strategic Partners LLC",
                dateAdded: Calendar.current.date(byAdding: .day, value: -20, to: Date()) ?? Date()
            )
        ]
        
        isLoading = false
    }
    
    private func addClient(_ client: Client) {
        var clientWithId = client
        if clientWithId.id == nil { clientWithId.id = UUID().uuidString }
        clients.insert(clientWithId, at: 0) // Always insert immediately for instant UI update
        Task {
            do {
                try await firebaseService.addClient(clientWithId)
                // Do not reload from Firebase/sample data after adding
            } catch {
                print("Error adding client: \(error)")
                // Already inserted for demo, so no further action needed
            }
        }
    }
    
    private func deleteClient(_ client: Client) {
        Task {
            do {
                try await firebaseService.deleteClient(client)
                await loadClients()
            } catch {
                print("Error deleting client: \(error)")
                // For demo purposes, remove from local array
                clients.removeAll { $0.id == client.id }
            }
        }
    }
}

// MARK: - Supporting Views

struct ClientRow: View {
    let client: Client
    
    var body: some View {
        Group {
            if #available(iOS 18.0, *) {
                HStack {
                    // Client Icon
                    Image(systemName: "person.crop.circle.fill")
                        .foregroundColor(.purple)
                        .frame(width: 40, height: 40)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(8)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(client.name)
                            .font(.headline)
                            .fontWeight(.medium)
                        if let company = client.company {
                            Text(company)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 8)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            } else {
                HStack {
                    // Client Icon
                    Image(systemName: "person.crop.circle.fill")
                        .foregroundColor(.purple)
                        .frame(width: 40, height: 40)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(8)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(client.name)
                            .font(.headline)
                            .fontWeight(.medium)
                        if let company = client.company {
                            Text(company)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
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

struct AddClientView: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: (Client) -> Void
    
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var company = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Client Information") {
                    TextField("Full Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                }
                
                Section("Company Details") {
                    TextField("Company Name", text: $company)
                    TextField("Address", text: $address, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("New Client")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveClient()
                    }
                    .disabled(name.isEmpty || email.isEmpty || phone.isEmpty)
                }
            }
        }
    }
    
    private func saveClient() {
        let client = Client(
            name: name,
            email: email,
            phone: phone,
            address: address.isEmpty ? nil : address,
            company: company.isEmpty ? nil : company,
            dateAdded: Date()
        )
        
        onSave(client)
        dismiss()
    }
}

#Preview {
    ClientsView()
        .environmentObject(FirebaseService())
} 
