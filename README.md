 <h1>Savify 💰</h1>

A modern Flutter finance tracker app powered by AI agents for intelligent financial management and insights.

---

## Demo Video Link

[YouTube Video Link](https://youtu.be/TGuGiL23uPU)

---

## Frontend Repository

Savify-Frontend: [GitHub Link](https://github.com/MumbaiHacks-NeoMind/Savify-Website.git)

---

## Backend Repository

Savify-Backend: [GitHub Link](https://github.com/MumbaiHacks-NeoMind/Savify-Backend.git)

---

## About Savify

### **What we plan to build**
We aim to build an *Agentic AI Financial Coaching Assistant* that learns from each user’s financial behavior and continuously adapts its advice. The platform will integrate financial data from multiple sources—bank transactions, e-wallets, gig payments, and manual entries—to provide real-time insights, personalized recommendations, and proactive alerts. At its core, the system includes five intelligent modules:

* *Finance Tracker* to monitor income, expenses, savings, liabilities, and cash flow, all displayed on a smart dashboard.
* *Analyzer & Insights Engine* to detect spending patterns, overspending triggers, recurring financial leaks, and potential saving opportunities.
* *Financial Planner* to help users create personalized financial goals and automatically generate plans for budgeting, saving, and investment.
* *Smart Tagging System* to automatically categorize expenditures such as bills, EMIs, groceries, travel, subscriptions, and flag unusual financial activity.
* *Master Agent AI* that autonomously prioritizes financial tasks like budgeting, bill reminders, EMI alerts, and nudges users for investments or savings.

Overall, we’re building a smart finance companion that not only tracks money but actively *guides, coaches, and optimizes users' financial decisions* in real-time.

## **What specific pain points it addresses**

Many individuals struggle with mismatched budgets, untracked expenses, loan burdens, and lack of financial clarity. Our AI platform solves this by giving users a clear and accurate picture of income vs. spending, highlighting unnecessary expenses, and helping manage EMIs or loans efficiently. It also addresses irregular income challenges faced by freelancers and gig workers by forecasting low-income months and suggesting financial buffers. Unlike static finance apps, our system provides personalized, dynamic, and actionable financial guidance—helping users stay disciplined with nudges, alerts, and goal trackers. Ultimately, it reduces stress around money management and helps people make smarter financial decisions effortlessly.

## **Who the target audience is**
Our primary audience includes gig workers and freelancers with fluctuating incomes, students and early professionals beginning their financial journey, and young adults seeking personalized financial discipline tools. It is also valuable for individuals in the informal sector, people managing loans or EMIs, and anyone who wants AI-powered assistance for budgeting, saving, or investment planning. Simply put, it’s built for everyday individuals who struggle to track, plan, and optimize their finances on their own.

## **Go-To-Market (GTM) Strategy & Revenue Streams**
We will launch using a freemium model, offering core finance tracking for free and premium AI-driven planning, deeper insights, and personalized investment advice under paid plans. For distribution, we’ll partner with digital banks, UPI platforms, and gig economy apps to enable easy onboarding and financial data integration. Growth will be driven through financial influencers, social media content, referral rewards, and community-building campaigns.

Revenue will primarily come from subscription plans, followed by affiliate commissions on recommended financial products like insurance, mutual funds, or credit optimization tools. Additional revenue sources include API services for fintech platforms, personalized financial coaching sessions, and potential white-label licensing to financial institutions.

---

## Features ✨

### Core Functionality
- **Transaction Management**: Track income and expenses with detailed categorization
- **Real-time Balance**: Monitor your total balance, income, and expenses at a glance
- **Category-based Tracking**: Organize transactions across multiple categories (Food, Transport, Shopping, Bills, etc.)
- **Visual Analytics**: Interactive pie charts showing spending distribution by category

### AI-Powered Features 🤖
- **Smart Insights**: AI agent automatically analyzes your spending patterns and provides personalized insights
- **Financial Advice**: Ask the AI assistant questions about budgeting, saving, and investing
- **Spending Alerts**: Get warned when expenses are too high relative to income
- **Category Analysis**: AI identifies your highest spending categories and suggests optimizations
- **Savings Recommendations**: Receive suggestions for how to allocate your savings

### User Experience
- **Material Design 3**: Modern, beautiful UI with light and dark theme support
- **Intuitive Navigation**: Bottom navigation bar for easy access to all features
- **Quick Actions**: Swipe to delete transactions
- **Date Selection**: Choose transaction dates with an integrated date picker
- **Real-time Updates**: All changes reflect immediately across the app

---

## Screenshots 📱

The app includes three main screens:

1. **Home Screen**: Overview of your balance, quick stats, and recent transactions
2. **Transactions Screen**: Complete list of all transactions with filtering options
3. **AI Insights Screen**: AI-generated insights and an interactive AI assistant

## Technology Stack 🛠️

- **Framework**: Flutter 3.0+
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Charts**: FL Chart
- **AI Integration**: Google Generative AI (Gemini)
- **UI/UX**: Material Design 3, Google Fonts

---

## Getting Started 🚀

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher

### Installation

1. Clone the repository:
```bash
git clone https://github.com/nidhisingh5958/Savify.git
cd Savify
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

---

## Project Structure 📁

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── transaction.dart
│   ├── budget.dart
│   └── ai_insight.dart
├── providers/                # State management
│   ├── transaction_provider.dart
│   └── ai_agent_provider.dart
├── screens/                  # App screens
│   ├── home_screen.dart
│   ├── transactions_screen.dart
│   ├── ai_insights_screen.dart
│   └── add_transaction_screen.dart
├── widgets/                  # Reusable widgets
│   ├── balance_card.dart
│   ├── quick_stats.dart
│   └── recent_transactions.dart
└── services/                 # Business logic
    └── ai_agent_service.dart
```

---

## How It Works 🔍

### Transaction Tracking
1. Add transactions using the floating action button
2. Categorize each transaction (Income or Expense)
3. View all transactions in the Transactions screen
4. Delete unwanted transactions with a swipe gesture

### AI Agent Features
The AI agent analyzes your financial data to provide:
- **Spending Pattern Detection**: Identifies categories where you spend the most
- **High Spending Alerts**: Warns when expenses exceed a healthy percentage of income
- **Savings Suggestions**: Recommends how to allocate surplus income
- **Interactive Chat**: Ask questions and get personalized financial advice

### Data Persistence
All data is stored locally using SharedPreferences, ensuring:
- Fast access to your financial data
- Privacy (no data sent to external servers)
- Offline functionality

## Future Enhancements 🔮

- [ ] Budget setting and tracking per category
- [ ] Recurring transactions
- [ ] Export data to CSV/PDF
- [ ] Multi-currency support
- [ ] Cloud sync across devices
- [ ] Advanced AI predictions using real ML models
- [ ] Financial goal setting and tracking
- [ ] Bill reminders and notifications

## New: Agentic Loan Sales Chatbot (SynFin Assistant)

This repository now includes a simple, local mock of an Agentic AI sales assistant that simulates the NBFC personal-loan workflow described in the project diagram.

Files added:
- `lib/services/worker_agents.dart` — Mock worker agents (KYC/credit score, underwriting, sanction letter generation).
- `lib/services/agent_master.dart` — A MasterAgent which orchestrates worker agents and drives a short conversational flow.
- `lib/screens/chatbot_screen.dart` — Simple chat UI to interact with the MasterAgent.

How it works (local mock):
- Open the app and tap the chat icon in the top-right of the Home screen.
- Type a message mentioning a loan (e.g., "I want a loan of 200000").
- The MasterAgent will simulate verification, underwriting, and sanction-letter generation and show status updates in the chat.

Notes:
- This is a mocked local simulation for UI and orchestration testing — no external APIs are called.
- The sanction letter is returned as a text placeholder (not a real PDF). Replace with real PDF generation or API calls for production.

---

## Contact 📧

For questions or suggestions, please open an issue on GitHub.

---

Made with ❤️ using Flutter and AI
