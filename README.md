# SpendWise: Student Expense Tracker (iOS)

SpendWise is a native iOS app that helps students record, track and analyse their daily expenses. It was built as an **iOS Lab Project** using **Swift** and **SwiftUI**.

---

## Project Team

| Name | Roll No. |
|---|---|
| Sidhant Kumar Pandey | 2502221530182 |
| Vansh Saxena | 2502221530199 |

**Under the mentorship of:** Anjali Srivastava

**Course / Lab:** iOS Lab Project

---

## Problem Statement

Students usually live on a limited allowance and often cannot say where their money went by the end of the month. Most finance apps are built for working adults and are too complex for this need. SpendWise offers a simple, student-friendly way to log expenses, set a monthly budget and see spending patterns at a glance.

---

## Features

### Account
- **Create Account** with name, email and password (with validation).
- **Login / Logout** with a persistent session, so the user stays logged in after closing the app.
- Passwords are stored as a **SHA-256 hash**, never as plain text.

### Expense Management
- **Add, edit and delete** expenses.
- Six categories with icons and colours: Food, Transport, Books, Rent, Fun, Other.
- Each expense stores amount, category, note and date.
- **Search** expenses by note or category.

### Budget and Analytics
- **Monthly budget** with a progress bar that turns green, orange (80% used) or red (over budget).
- **Date-range filter**: pick a From and To date to see the total, category chart and expense list for that period. Quick buttons: This Month, Last Month, All Time.
- **Bar chart** of spending by category on the Home tab.
- **Donut chart** with a percentage breakdown on the Stats tab.

### UPI Payments (launcher)
- Choose a UPI app (Google Pay, PhonePe, Paytm, CRED or another UPI app) and open it with the payee, amount and note pre-filled.
- After returning, the app asks "Did the payment go through?" and, if confirmed, saves the expense with the note, the time the payment was started, and the app used.
- A **"Save to my expenses"** switch lets the user pay without SpendWise storing anything.
- Payments made directly inside UPI apps are never recorded, because iOS does not allow apps to read other apps' payment data.

### Reports
- **Export to CSV** from the Profile tab. The file contains Date, Time, Category, Note, Amount, Payee and Paid Via, and can be saved to Files, sent by AirDrop or email, and opened in Excel or Google Sheets.

### Navigation
- Four-tab layout: **Home, History, Stats, Profile**.

---

## Tech Stack

| Area | Technology |
|---|---|
| Language | Swift |
| UI framework | SwiftUI |
| Charts | Swift Charts |
| Local storage | UserDefaults with JSON encoding (Codable) |
| Password hashing | CryptoKit (SHA-256) |
| Architecture | MVVM-style (ObservableObject stores and SwiftUI views) |
| IDE | Xcode |
| Version control | Git and GitHub |

---

## Project Structure

```
Student Expense/
├── Student_ExpenseApp.swift     App entry point; shows Login or the main tabs
├── models/
│   ├── expense.swift            Expense model and ExpenseCategory enum
│   ├── ExpenseStore.swift       Expense data, budget, totals, save/load
│   ├── AuthManager.swift        Sign up, login, logout, password hashing
│   └── CSVExporter.swift        CSV file creation and share sheet
└── views/
    ├── LoginView.swift          Login screen
    ├── SignUpView.swift         Create-account screen
    ├── MainTabView.swift        Tab bar container
    ├── ContentView.swift        Home: date filter, budget, chart, expenses
    ├── HistoryView.swift        Full expense list with search
    ├── StatsView.swift          Donut chart and category breakdown
    ├── ProfileView.swift        Profile, summary, CSV export, log out
    ├── AddExpenseView.swift     Add / edit expense form
    └── PayView.swift            UPI payment launcher
```

---

## How It Works

1. **Launch:** `Student_ExpenseApp` checks `AuthManager`. If no user is logged in, `LoginView` is shown; otherwise `MainTabView` opens.
2. **Data:** `ExpenseStore` holds the list of expenses and the monthly budget. Every change is saved automatically to UserDefaults as JSON and reloaded on the next launch.
3. **Views:** each tab observes the same `ExpenseStore`, so adding an expense on Home updates History, Stats and Profile instantly.
4. **Budget logic:** `monthTotal` sums the expenses of the current calendar month and is compared with the budget to drive the progress bar.
5. **UPI:** `PayView` builds a UPI deep link and opens the chosen app. When the user returns, the app detects the foreground change and asks for confirmation before saving.

---

## Getting Started

### Requirements
- A Mac with **Xcode 16** or later
- iOS **17** or later (simulator or device)

### Run the app
1. Clone the repository:
   ```bash
   git clone https://github.com/itsvansh-droid/EXPENSE-TRACKER-FINAL.git
   ```
2. Open the `.xcodeproj` file in Xcode.
3. Select an iPhone simulator (for example iPhone 16 Pro).
4. Press **Cmd + R** to build and run.
5. Tap **Create one** on the login screen, make an account, and start adding expenses.

### Testing UPI payments
The simulator has no UPI apps installed. To test this feature:
1. Use a real iPhone with a UPI app installed and turn on **Developer Mode**.
2. In Xcode, open the project's **Info** tab and add **Queried URL Schemes** with the values `gpay`, `phonepe`, `paytmmp`, `credpay`, `upi`.
3. Run the app on the phone and use a small amount (for example ₹1) for testing.

---

## Limitations

- **Local storage only:** data is stored on the device. There is no cloud backup or sync.
- **Shared expenses on one device:** accounts are stored locally, and all accounts on the same device currently see the same expense list.
- **Basic password security:** passwords are hashed with SHA-256 without a salt. A production app should use a backend with salted hashing.
- **UPI is a launcher, not a payment gateway:** iOS does not return payment status to third-party apps, so the user confirms success manually. The saved time is when the payment was started, not the bank's timestamp.
- Some UPI apps may reject payments to merchants through deep links, and app URL schemes can change over time.

---

## Future Scope

- Per-user expense data
- Cloud sync and login through a backend (for example Firebase)
- Income tracking and balance
- Per-category budgets and savings goals
- Recurring expenses and reminder notifications
- Face ID lock
- Real payment integration through a payment provider

---

## Acknowledgements

This project was developed as part of the iOS Lab under the guidance of **Anjali Srivastava**. We thank her for her mentorship and support.

---

## Team

- **Sidhant Kumar Pandey** (Roll No. 2502221530182)
- **Vansh Saxena** (Roll No. 2502221530199)

Mentor: **Anjali Srivastava**
