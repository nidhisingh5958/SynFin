# Frontend Integration Guide

## Quick Start

The Financial AI System provides a single, intelligent endpoint that handles all types of financial queries.

### Basic Integration

```javascript
const API_BASE = 'http://localhost:8000';

// Simple chat function
async function sendMessage(message, userContext = '', expenditureData = null) {
  const response = await fetch(`${API_BASE}/chat`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      message,
      user_context: userContext,
      expenditure_data: expenditureData
    })
  });
  
  return await response.json();
}
```

### Usage Examples

#### 1. General Financial Chat
```javascript
const response = await sendMessage(
  "How can I save money on groceries?",
  "College student with limited budget"
);
// Returns: insights_generation with personalized advice
```

#### 2. Expenditure Analysis
```javascript
const expenses = [
  {
    amount: 50.0,
    category: "food",
    description: "Grocery shopping",
    date: "2024-01-15T10:30:00"
  },
  {
    amount: 30.0,
    category: "transport", 
    description: "Bus fare",
    date: "2024-01-15T08:00:00"
  }
];

const response = await sendMessage(
  "Analyze my spending",
  "Student budget",
  expenses
);
// Returns: expenditure_analysis with detailed breakdown
```

#### 3. Tax Advice
```javascript
const response = await sendMessage(
  "What tax deductions can I claim as a freelancer?",
  "Freelance developer"
);
// Returns: tax_advice with specific recommendations
```

## React Integration Example

```jsx
import React, { useState } from 'react';

function FinancialChat() {
  const [message, setMessage] = useState('');
  const [response, setResponse] = useState(null);
  const [expenses, setExpenses] = useState([]);

  const sendMessage = async () => {
    try {
      const res = await fetch('http://localhost:8000/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          message,
          expenditure_data: expenses.length > 0 ? expenses : null
        })
      });
      
      const data = await res.json();
      setResponse(data);
    } catch (error) {
      console.error('Error:', error);
    }
  };

  return (
    <div>
      <textarea 
        value={message}
        onChange={(e) => setMessage(e.target.value)}
        placeholder="Ask about your finances..."
      />
      <button onClick={sendMessage}>Send</button>
      
      {response && (
        <div>
          <h3>Response ({response.query_type})</h3>
          <p>{response.response}</p>
          {response.data && (
            <pre>{JSON.stringify(response.data, null, 2)}</pre>
          )}
        </div>
      )}
    </div>
  );
}
```

## Response Handling

### Query Type Detection
The system automatically detects query intent:

```javascript
const response = await sendMessage("Should I invest in stocks?");
console.log(response.query_type); // "investment_advice"

const response2 = await sendMessage("Analyze my expenses", "", expenses);
console.log(response2.query_type); // "expenditure_analysis"
```

### Structured Data Access
Some responses include structured data:

```javascript
if (response.query_type === 'expenditure_analysis') {
  const analysis = response.data;
  console.log(`Total: $${analysis.total_spending}`);
  console.log('Categories:', analysis.category_breakdown);
}
```

## Error Handling

```javascript
async function safeApiCall(message) {
  try {
    const response = await fetch(`${API_BASE}/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message })
    });
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }
    
    return await response.json();
  } catch (error) {
    return {
      response: "Sorry, I'm having trouble processing your request.",
      query_type: "error"
    };
  }
}
```

## TypeScript Definitions

```typescript
interface ExpenditureEntry {
  amount: number;
  category: string;
  description: string;
  date: string; // ISO datetime
}

interface ChatRequest {
  message: string;
  user_context?: string;
  expenditure_data?: ExpenditureEntry[];
}

interface ChatResponse {
  response: string;
  query_type: 'expenditure_analysis' | 'insights_generation' | 'tax_advice' | 
              'investment_advice' | 'revenue_analysis' | 'general_chat';
  data?: any;
}
```

## Best Practices

1. **Always handle errors gracefully**
2. **Show query type to users** for transparency
3. **Cache responses** for better UX
4. **Validate expense data** before sending
5. **Provide loading states** during API calls
6. **Use structured data** when available for rich UI