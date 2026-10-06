import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthManager

    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                headerSection
                fieldsSection
                errorSection
                loginButton
                signUpLink
                Spacer()
            }
            .padding(24)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "indianrupeesign.circle.fill")
                .font(.system(size: 70))
                .foregroundStyle(.blue)
            Text("SpendWise")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Log in to track your expenses")
                .foregroundStyle(.secondary)
        }
        .padding(.top, 40)
    }

    private var fieldsSection: some View {
        VStack(spacing: 14) {
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            SecureField("Password", text: $password)
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

    private var loginButton: some View {
        Button {
            if let error = auth.login(email: email, password: password) {
                errorMessage = error
            }
        } label: {
            Text("Log In")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var signUpLink: some View {
        NavigationLink {
            SignUpView()
        } label: {
            Text("Don't have an account? Create one")
                .font(.subheadline)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}
