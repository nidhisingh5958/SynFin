# API Reference

Base URL: `http://localhost:8000`

## Authentication
No authentication required for local development. Set `GROQ_API_KEY` environment variable.

## Endpoints

### POST /chat
**Primary endpoint - handles all query types intelligently**

```http
POST /chat
Content-Type: application/json

{
  "message": "string",
  "user_context": "string (optional)",
  "expenditure_data": [ExpenditureEntry] (optional)
}
```

**Response:**
```json
{
  "response": "string",
  "query_type": "expenditure_analysis|insights_generation|tax_advice|investment_advice|revenue_analysis|general_chat",
  "data": {} // Optional structured data
}
```

### POST /analyze-expenditure
**Direct expenditure analysis**

```http
POST /analyze-expenditure
Content-Type: application/json

[
  {
    "amount": 50.0,
    "category": "food",
    "description": "Grocery shopping",
    "date": "2024-01-15T10:30:00"
  }
]
```

### POST /full-analysis
**Complete pipeline: analysis + insights**

```http
POST /full-analysis
Content-Type: application/json

{
  "entries": [ExpenditureEntry],
  "user_context": "string (optional)"
}
```

## Data Models

### ExpenditureEntry
```json
{
  "amount": "float (required)",
  "category": "string (required)",
  "description": "string (required)", 
  "date": "datetime (ISO format, required)"
}
```

### ChatRequest
```json
{
  "message": "string (required)",
  "user_context": "string (optional)",
  "expenditure_data": "[ExpenditureEntry] (optional)"
}
```

### ChatResponse
```json
{
  "response": "string",
  "query_type": "QueryType enum",
  "data": "object (optional)"
}
```

## Query Types

- `expenditure_analysis`: Spending pattern analysis
- `insights_generation`: Financial recommendations
- `tax_advice`: Tax-related guidance
- `investment_advice`: Investment recommendations
- `revenue_analysis`: Income/revenue analysis
- `general_chat`: General financial questions

## Error Responses

```json
{
  "detail": "Error message"
}
```

Common HTTP status codes:
- `400`: Bad Request (missing/invalid data)
- `500`: Internal Server Error (processing failed)