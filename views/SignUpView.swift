import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var auth: AuthManager

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 24) {
            headerSection
            fieldsSection
            errorSection
            createButton
            Spacer()
        }
        .padding(24)
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            Text("Join SpendWise")
                .font(.title2)
                .fontWeight(.bold)
        }
        .padding(.top, 20)
    }

    private var fieldsSection: some View {
        VStack(spacing: 14) {
            TextField("Full name", text: $name)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            SecureField("Password (min 6 characters)", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            SecureField("Confirm password", text: $confirmPassword)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    @ViewBuilder
    private var errorSection: some View {
        if !errorMessage.isEmpty {
            Text(errorMessage)
                .font(.footnote)
                .foregroundStyle(.red)
                .multilineTextAlignment(.center)
        }
    }

    private var createButton: some View {
        Button {
            createAccount()
        } label: {
            Text("Create Account")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func createAccount() {
        if password != confirmPassword {
            errorMessage = "Passwords do not match."
            return
        }
        if let error = auth.signUp(name: name, email: email, password: password) {
            errorMessage = error
        }
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(AuthManager())
    }
}
