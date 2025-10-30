# Examples & Use Cases

## Complete Integration Examples

### 1. Expense Tracking App

```javascript
class ExpenseTracker {
  constructor() {
    this.apiBase = 'http://localhost:8000';
    this.expenses = [];
  }

  async addExpense(amount, category, description) {
    const expense = {
      amount: parseFloat(amount),
      category,
      description,
      date: new Date().toISOString()
    };
    
    this.expenses.push(expense);
    return expense;
  }

  async getAnalysis() {
    const response = await fetch(`${this.apiBase}/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        message: "Analyze my spending patterns",
        expenditure_data: this.expenses
      })
    });
    
    return await response.json();
  }

  async getInsights(userContext = "") {
    const response = await fetch(`${this.apiBase}/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        message: "Give me financial insights and recommendations",
        user_context: userContext,
        expenditure_data: this.expenses
      })
    });
    
    return await response.json();
  }
}

// Usage
const tracker = new ExpenseTracker();
await tracker.addExpense(50, "food", "Groceries");
await tracker.addExpense(30, "transport", "Bus fare");

const analysis = await tracker.getAnalysis();
console.log(analysis.response);
// "I've analyzed your expenditure data: Total Spending: $80.00..."

const insights = await tracker.getInsights("College student");
console.log(insights.query_type); // "insights_generation"
```

### 2. Financial Chatbot

```jsx
import React, { useState, useEffect } from 'react';

function FinancialChatbot() {
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState('');
  const [expenses, setExpenses] = useState([]);

  const sendMessage = async (message) => {
    // Add user message
    setMessages(prev => [...prev, { type: 'user', content: message }]);

    try {
      const response = await fetch('http://localhost:8000/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          message,
          expenditure_data: expenses.length > 0 ? expenses : null
        })
      });

      const data = await response.json();
      
      // Add bot response with query type
      setMessages(prev => [...prev, { 
        type: 'bot', 
        content: data.response,
        queryType: data.query_type,
        data: data.data
      }]);
    } catch (error) {
      setMessages(prev => [...prev, { 
        type: 'bot', 
        content: 'Sorry, I encountered an error. Please try again.'
      }]);
    }
  };

  const quickActions = [
    "Analyze my spending",
    "Give me budgeting tips", 
    "How can I save on taxes?",
    "Should I invest in stocks?",
    "Help me track expenses"
  ];

  return (
    <div className="chatbot">
      <div className="messages">
        {messages.map((msg, idx) => (
          <div key={idx} className={`message ${msg.type}`}>
            <div className="content">{msg.content}</div>
            {msg.queryType && (
              <div className="query-type">Type: {msg.queryType}</div>
            )}
            {msg.data && (
              <details>
                <summary>View Data</summary>
                <pre>{JSON.stringify(msg.data, null, 2)}</pre>
              </details>
            )}
          </div>
        ))}
      </div>

      <div className="input-area">
        <input
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyPress={(e) => e.key === 'Enter' && sendMessage(input)}
          placeholder="Ask about your finances..."
        />
        <button onClick={() => sendMessage(input)}>Send</button>
      </div>

      <div className="quick-actions">
        {quickActions.map(action => (
          <button key={action} onClick={() => sendMessage(action)}>
            {action}
          </button>
        ))}
      </div>
    </div>
  );
}
```

## Query Examples by Type

### Expenditure Analysis
```javascript
// With expense data
const response = await sendMessage(
  "Break down my spending by category",
  "",
  [
    { amount: 120, category: "food", description: "Groceries", date: "2024-01-15T10:00:00" },
    { amount: 50, category: "transport", description: "Gas", date: "2024-01-15T08:00:00" },
    { amount: 80, category: "food", description: "Restaurant", date: "2024-01-14T19:00:00" }
  ]
);

// Expected response:
// {
//   "response": "I've analyzed your expenditure data:\n• Total Spending: $250.00\n• Categories: 2\n• Top Category: food\n\nYour spending shows...",
//   "query_type": "expenditure_analysis",
//   "data": {
//     "total_spending": 250.0,
//     "category_breakdown": {"food": 200.0, "transport": 50.0},
//     "spending_patterns": {...}
//   }
// }
```

### Insights Generation
```javascript
const response = await sendMessage(
  "How can I improve my financial health?",
  "Recent graduate with student loans"
);

// Expected response:
// {
//   "response": "Based on your situation as a recent graduate with student loans, here are personalized recommendations...",
//   "query_type": "insights_generation"
// }
```

### Tax Advice
```javascript
const response = await sendMessage(
  "What business expenses can I deduct?",
  "Freelance web developer"
);

// Expected response:
// {
//   "response": "As a freelance web developer, you can deduct several business expenses: 1. Home office expenses...",
//   "query_type": "tax_advice"
// }
```

### Investment Advice
```javascript
const response = await sendMessage(
  "Should I invest in index funds or individual stocks?",
  "25 years old, stable income, low risk tolerance"
);

// Expected response:
// {
//   "response": "Given your age and low risk tolerance, index funds would be more suitable...",
//   "query_type": "investment_advice"
// }
```

## Advanced Use Cases

### 1. Budget Monitoring Dashboard

```javascript
class BudgetDashboard {
  constructor() {
    this.apiBase = 'http://localhost:8000';
  }

  async getBudgetAnalysis(expenses, budgetLimits) {
    const message = `Analyze my spending against these budget limits: ${JSON.stringify(budgetLimits)}`;
    
    const response = await fetch(`${this.apiBase}/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        message,
        expenditure_data: expenses,
        user_context: "Budget monitoring"
      })
    });
    
    return await response.json();
  }

  async getSpendingTrends(monthlyExpenses) {
    const message = "Analyze my spending trends over time";
    
    const response = await fetch(`${this.apiBase}/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        message,
        expenditure_data: monthlyExpenses.flat(),
        user_context: "Monthly trend analysis"
      })
    });
    
    return await response.json();
  }
}
```

### 2. Financial Goal Tracker

```javascript
class GoalTracker {
  async checkGoalProgress(expenses, goal) {
    const message = `Help me track progress toward my goal: ${goal.description}. Target: $${goal.target} by ${goal.deadline}`;
    
    const response = await fetch('http://localhost:8000/chat', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        message,
        expenditure_data: expenses,
        user_context: `Goal: ${goal.description}, Current savings: $${goal.currentSavings}`
      })
    });
    
    return await response.json();
  }
}
```

### 3. Multi-User Family Budget

```javascript
class FamilyBudget {
  async analyzeFamilySpending(familyMembers) {
    const allExpenses = familyMembers.flatMap(member => 
      member.expenses.map(expense => ({
        ...expense,
        member: member.name
      }))
    );

    const message = "Analyze our family spending patterns and suggest optimizations";
    
    const response = await fetch('http://localhost:8000/chat', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        message,
        expenditure_data: allExpenses,
        user_context: `Family of ${familyMembers.length} members`
      })
    });
    
    return await response.json();
  }
}
```

## Error Handling Examples

### Robust API Client

```javascript
class FinancialAPIClient {
  constructor(baseUrl = 'http://localhost:8000') {
    this.baseUrl = baseUrl;
  }

  async chat(message, userContext = '', expenditureData = null, retries = 3) {
    for (let i = 0; i < retries; i++) {
      try {
        const response = await fetch(`${this.baseUrl}/chat`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            message,
            user_context: userContext,
            expenditure_data: expenditureData
          }),
          timeout: 30000 // 30 second timeout
        });

        if (!response.ok) {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        return await response.json();
      } catch (error) {
        console.warn(`Attempt ${i + 1} failed:`, error.message);
        
        if (i === retries - 1) {
          return {
            response: "I'm having trouble processing your request right now. Please try again later.",
            query_type: "error",
            error: error.message
          };
        }
        
        // Wait before retry
        await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
      }
    }
  }
}
```

## Testing Examples

### Unit Tests for Frontend Integration

```javascript
// Jest test example
describe('Financial API Integration', () => {
  test('should classify expenditure analysis query', async () => {
    const expenses = [
      { amount: 50, category: "food", description: "Lunch", date: new Date().toISOString() }
    ];
    
    const response = await sendMessage("Analyze my spending", "", expenses);
    
    expect(response.query_type).toBe('expenditure_analysis');
    expect(response.data).toHaveProperty('total_spending');
    expect(response.data.total_spending).toBe(50);
  });

  test('should handle tax advice queries', async () => {
    const response = await sendMessage("How do I file taxes?");
    
    expect(response.query_type).toBe('tax_advice');
    expect(response.response).toContain('tax');
  });
});
```