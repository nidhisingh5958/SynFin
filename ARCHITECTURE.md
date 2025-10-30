# Savify AI Integration Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Savify Flutter App                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    UI Layer (Screens)                       │ │
│  ├────────────────────────────────────────────────────────────┤ │
│  │                                                             │ │
│  │  • home_screen.dart              Dashboard & Overview      │ │
│  │  • transactions_screen.dart      Transaction List          │ │
│  │  • ai_insights_screen.dart       AI Chat & Insights ⭐     │ │
│  │  • add_transaction_screen.dart   Add/Edit Transactions     │ │
│  │                                                             │ │
│  └─────────────────────┬───────────────────────────────────────┘ │
│                        │                                          │
│                        ▼                                          │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              State Management (Provider)                    │ │
│  ├────────────────────────────────────────────────────────────┤ │
│  │                                                             │ │
│  │  • TransactionProvider      Manages transactions & budget  │ │
│  │  • AIAgentProvider ⭐        Manages AI state & responses  │ │
│  │                                                             │ │
│  └─────────────────────┬───────────────────────────────────────┘ │
│                        │                                          │
│                        ▼                                          │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                   Service Layer                             │ │
│  ├────────────────────────────────────────────────────────────┤ │
│  │                                                             │ │
│  │  • AIAgentService ⭐         HTTP API Client                │ │
│  │    - sendChatMessage()       Send queries to AI            │ │
│  │    - generateInsights()      Get automatic insights        │ │
│  │    - analyzeExpenditure()    Detailed spending analysis    │ │
│  │    - getInvestmentAdvice()   Investment recommendations    │ │
│  │    - getTaxAdvice()          Tax planning tips             │ │
│  │    - checkBackendHealth()    Backend status check          │ │
│  │                                                             │ │
│  └─────────────────────┬───────────────────────────────────────┘ │
│                        │                                          │
│                        ▼                                          │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    Data Models                              │ │
│  ├────────────────────────────────────────────────────────────┤ │
│  │                                                             │ │
│  │  • Transaction          Core transaction model             │ │
│  │  • AIInsight            AI-generated insights              │ │
│  │  • ExpenditureEntry ⭐   Transaction → API format          │ │
│  │  • ChatRequest ⭐        API request model                  │ │
│  │  • ChatResponse ⭐       API response model                 │ │
│  │  • ExpenditureAnalysis ⭐ Analysis data model              │ │
│  │                                                             │ │
│  └─────────────────────┬───────────────────────────────────────┘ │
│                        │                                          │
└────────────────────────┼──────────────────────────────────────────┘
                         │
                         │ HTTP POST/GET
                         │ (JSON)
                         │
                         ▼
         ┌───────────────────────────────────────┐
         │   Financial AI System V2 Backend      │
         │   http://localhost:8000               │
         ├───────────────────────────────────────┤
         │                                       │
         │  API Endpoints:                       │
         │  • POST /chat                         │
         │    - message: string                  │
         │    - user_context: string (optional)  │
         │    - expenditure_data: array          │
         │                                       │
         │  Response:                            │
         │  • response: string                   │
         │  • query_type: string                 │
         │  • data: object (optional)            │
         │                                       │
         └───────────────┬───────────────────────┘
                         │
                         ▼
         ┌───────────────────────────────────────┐
         │        AI Agent System                │
         ├───────────────────────────────────────┤
         │                                       │
         │  • Query Classifier                   │
         │  • Expenditure Analyzer               │
         │  • Insights Generator                 │
         │  • Tax Advisor                        │
         │  • Investment Advisor                 │
         │  • LangChain Orchestration            │
         │  • OpenAI GPT Integration             │
         │                                       │
         └───────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════

                         Data Flow Example
                         
┌──────────────┐
│ User taps    │
│ "Send" in    │  1. User Input
│ AI Chat      │────────────────┐
└──────────────┘                │
                                ▼
                    ┌───────────────────────────┐
                    │ AIInsightsScreen          │
                    │ Captures: "Analyze my     │
                    │ spending this month"      │
                    └───────────┬───────────────┘
                                │ 2. Call Provider
                                ▼
                    ┌───────────────────────────┐
                    │ AIAgentProvider           │
                    │ .sendMessage()            │
                    │ - Sets loading state      │
                    │ - Gets transactions       │
                    └───────────┬───────────────┘
                                │ 3. Service Call
                                ▼
                    ┌───────────────────────────┐
                    │ AIAgentService            │
                    │ - Converts transactions   │
                    │ - Creates ChatRequest     │
                    │ - HTTP POST to backend    │
                    └───────────┬───────────────┘
                                │ 4. API Call
                                ▼
                    ┌───────────────────────────┐
                    │ Backend API               │
                    │ /chat endpoint            │
                    │ - Classifies query type   │
                    │ - Processes with AI       │
                    │ - Returns ChatResponse    │
                    └───────────┬───────────────┘
                                │ 5. Response
                                ▼
                    ┌───────────────────────────┐
                    │ AIAgentService            │
                    │ - Parses JSON             │
                    │ - Creates ChatResponse    │
                    └───────────┬───────────────┘
                                │ 6. Update State
                                ▼
                    ┌───────────────────────────┐
                    │ AIAgentProvider           │
                    │ - Stores response         │
                    │ - Updates lastAdvice      │
                    │ - Clears loading state    │
                    │ - Notifies listeners      │
                    └───────────┬───────────────┘
                                │ 7. UI Update
                                ▼
                    ┌───────────────────────────┐
                    │ AIInsightsScreen          │
                    │ - Displays response       │
                    │ - Shows query type badge  │
                    │ - Renders AI advice       │
                    └───────────────────────────┘


═══════════════════════════════════════════════════════════════════

                      Key Components

┌─────────────────────────────────────────────────────────────────┐
│ Component              │ Responsibility                          │
├────────────────────────┼─────────────────────────────────────────┤
│ AIInsightsScreen       │ UI for AI chat and insights display     │
│ AIAgentProvider        │ State management for AI features        │
│ AIAgentService         │ API client, HTTP communication          │
│ ChatRequest            │ Request payload serialization           │
│ ChatResponse           │ Response payload deserialization        │
│ ExpenditureEntry       │ Transaction format for AI               │
│ ExpenditureAnalysis    │ Structured analysis data                │
└────────────────────────┴─────────────────────────────────────────┘


═══════════════════════════════════════════════════════════════════

                       Error Handling Flow

Backend Offline
    │
    ├─→ checkBackendHealth() returns false
    │
    ├─→ isBackendAvailable = false
    │
    ├─→ UI shows red status indicator
    │
    └─→ User sees warning banner

API Error
    │
    ├─→ HTTP request throws exception
    │
    ├─→ Service catches error
    │
    ├─→ Returns ChatResponse with error
    │
    └─→ UI shows error message with red border


═══════════════════════════════════════════════════════════════════

                     Response Type Detection

User Query: "Analyze my spending"
    │
    ├─→ Backend classifies as: expenditure_analysis
    │
    ├─→ Returns structured data + response text
    │
    ├─→ UI shows blue "Spending" badge
    │
    └─→ Can extract detailed breakdown from data

User Query: "Should I invest in stocks?"
    │
    ├─→ Backend classifies as: investment_advice
    │
    ├─→ Returns advice text
    │
    ├─→ UI shows green "Investment" badge
    │
    └─→ Displays personalized investment guidance


═══════════════════════════════════════════════════════════════════

Legend:
  ⭐ = New/Modified for AI integration
  → = Data flow direction
  │ = Process continuation
```
