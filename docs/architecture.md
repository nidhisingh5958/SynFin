# Architecture Deep Dive

## System Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Frontend      │    │   FastAPI        │    │   Groq LLM      │
│   (React/JS)    │◄──►│   Backend        │◄──►│   (AI Models)   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │   Master Agent   │
                    │   (Router)       │
                    └─────────┬────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ Expenditure  │    │   Insights   │    │  Financial   │
│   Analyzer   │    │    Agent     │    │   Advisors   │
└──────────────┘    └──────────────┘    └──────────────┘
```

## Core Components

### 1. Master Agent (`master_agent.py`)
**Role**: Intelligent query router and orchestrator

**Key Features**:
- AI-powered query classification using Groq LLM
- Fallback keyword-based classification
- Routes requests to appropriate specialized agents
- Handles all query types through unified interface

**Flow**:
```python
def process_user_input(request: ChatRequest) -> ChatResponse:
    1. Classify query using AI
    2. Route to appropriate handler
    3. Return unified response format
```

### 2. Expenditure Analyzer (`agents.py`)
**Role**: Processes and analyzes spending data

**Capabilities**:
- Calculates total spending and averages
- Categorizes expenses automatically
- Identifies spending patterns
- Generates AI-powered analysis summaries

**Data Processing**:
```python
def analyze_expenditure(entries: List[ExpenditureEntry]):
    - Total spending calculation
    - Category breakdown (defaultdict aggregation)
    - Pattern analysis (avg, highest category, counts)
    - AI summary generation via Groq LLM
```

### 3. Insights Agent (`agents.py`)
**Role**: Generates personalized financial recommendations

**Features**:
- Uses Groq LLM for intelligent insights
- Structured JSON response parsing
- Fallback recommendations for reliability
- Financial health scoring (1-100)

**Output Structure**:
```json
{
  "insights": ["Key behavioral insights"],
  "recommendations": ["Actionable advice"],
  "financial_score": 85,
  "summary": "Overall assessment"
}
```

### 4. FastAPI Application (`app.py`)
**Role**: HTTP API layer and request handling

**Endpoints**:
- `/chat` - Primary unified endpoint
- `/analyze-expenditure` - Direct analysis
- `/full-analysis` - Complete pipeline
- `/generate-insights` - Insights only

**Features**:
- CORS enabled for frontend integration
- Automatic request validation via Pydantic
- Error handling and HTTP status codes
- Auto-generated OpenAPI documentation

## Data Models (`models.py`)

### Core Models
```python
class ExpenditureEntry(BaseModel):
    amount: float
    category: str
    description: str
    date: datetime

class ChatRequest(BaseModel):
    message: str
    user_context: Optional[str] = ""
    expenditure_data: Optional[List[ExpenditureEntry]] = None

class ChatResponse(BaseModel):
    response: str
    query_type: QueryType
    data: Optional[Dict[str, Any]] = None
```

### Query Classification
```python
class QueryType(str, Enum):
    EXPENDITURE_ANALYSIS = "expenditure_analysis"
    INSIGHTS_GENERATION = "insights_generation"
    TAX_ADVICE = "tax_advice"
    INVESTMENT_ADVICE = "investment_advice"
    REVENUE_ANALYSIS = "revenue_analysis"
    GENERAL_CHAT = "general_chat"
```

## AI Integration

### Groq LLM Usage
The system uses Groq's LLM API for:

1. **Query Classification**: Intelligent intent detection
2. **Analysis Summaries**: Natural language expense summaries
3. **Insights Generation**: Personalized financial advice
4. **Domain-Specific Advice**: Tax, investment, revenue guidance

### LangChain Integration
```python
from langchain_groq import ChatGroq
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser

# Structured prompt templates
prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a financial analyst..."),
    ("user", "{user_input}")
])

# Chain composition
chain = prompt | llm | StrOutputParser()
```

## Request Flow

### 1. Chat Request Processing
```
User Input → Master Agent → Query Classification → Route to Handler → Generate Response
```

### 2. Expenditure Analysis Flow
```
Expense Data → Expenditure Analyzer → Pattern Analysis → AI Summary → Structured Response
```

### 3. Insights Generation Flow
```
Analysis Data → Insights Agent → LLM Processing → JSON Parsing → Formatted Response
```

## Error Handling Strategy

### Multi-Layer Fallbacks
1. **AI Failures**: Fallback to rule-based responses
2. **JSON Parsing**: Structured fallback responses
3. **Network Issues**: Graceful error messages
4. **Data Validation**: Pydantic automatic validation

### Example Fallback Chain
```python
try:
    # Primary: AI-generated response
    return ai_response
except Exception:
    try:
        # Secondary: Rule-based response
        return fallback_response
    except Exception:
        # Tertiary: Static safe response
        return default_response
```

## Performance Considerations

### Async Processing
- FastAPI async endpoints for concurrent requests
- Non-blocking I/O for LLM API calls
- Efficient data processing with pandas-like operations

### Caching Strategy
- Response caching for repeated queries
- Analysis result caching for large datasets
- LLM response caching for common patterns

### Scalability
- Stateless design for horizontal scaling
- Database integration ready (currently in-memory)
- Load balancer compatible architecture

## Security & Configuration

### Environment Variables
```bash
GROQ_API_KEY=your_api_key_here
```

### CORS Configuration
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

## Extension Points

### Adding New Query Types
1. Add to `QueryType` enum
2. Implement handler in `MasterAgent`
3. Update classification logic
4. Add specialized agent if needed

### Custom Agents
```python
class CustomAgent:
    def __init__(self):
        self.client = ChatGroq(api_key=os.getenv("GROQ_API_KEY"))
    
    def process(self, request: ChatRequest) -> ChatResponse:
        # Custom processing logic
        pass
```

### Database Integration
Ready for integration with:
- PostgreSQL for expense storage
- Redis for caching
- MongoDB for document storage