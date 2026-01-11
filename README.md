# TimeLog Microservices

Two Node.js microservices for collecting and storing time tracking data from a SQL Server database.

## Notes

This is a simplified project. In a real-world scenario, you should implement additional security features such as:

- Better, more robust implementation of requests, error handling, json-rpc servers. Probably even use of dedicated, well-proven npm packages
- Rate limiting to prevent abuse and denial-of-service attacks
- Input validation and sanitization to protect against SQL injection and other attacks
- Authentication and authorization to restrict access to sensitive endpoints
- HTTPS/TLS for secure data transmission
- Logging and monitoring for auditing and incident response
- Proper error handling to avoid leaking sensitive information
- Protection against common web vulnerabilities (e.g., CSRF, XSS)

These measures are essential for production systems but are omitted here for simplicity and educational purposes.

## Architecture

- **REST-Service (Data Collector)**: REST API that queries the database and forwards data to RPC-Service
- **RPC-Service (Data Storage)**: JSON-RPC service that stores request data in the Requests table

## Prerequisites

- Node.js 22+
- SQL Server database with User, Project, and TimeLog tables
- TypeScript and tsx for running TypeScript directly

## Configuration

Create `.env` files in the root of each project based on the `.env.example` files.

### Environment Variables

**REST-Service**
| Variable | Description | Default |
| ------------- | ---------------------------- | -------- |
| `DB_URI` | SQL Server connection string | Required |
| `SERVICE_NAME` | User-friendly name of the service | service1 |
| `PORT` | Port that the service should run on | 3000 |
| `RPC_URI` | URL of RPC-Service | Required |
| `RPC_METHOD` | Method for the RPC-Service | saveRequestSingle |

**RPC-Service**
| Variable | Description | Default |
| ------------- | ---------------------------- | -------- |
| `DB_URI` | SQL Server connection string | Required |
| `SERVICE_NAME` | User-friendly name of the service | service2 |
| `PORT` | Port that the service should run on | 3001 |

## Database Setup

Ensure the following tables exist in your SQL Server database:

- **User**: `id`, `first_name`, `last_name`, `email`
- **Project**: `id`, `project_name`
- **TimeLog**: `id`, `user_id`, `project_id`, `date`, `hours`
- **Requests**: `id`, `request_id`, `req_date`, `param`, `data`

All required tables can be created using the sql script `./sql/CreateTables.sql`.

## Running the Services

Start both services in separate terminals:

```bash
# Terminal 1 - Start RPC-Service
cd rpc-service
npm install # Run, if dependencies are not install yet
npm start

# Terminal 2 - Start REST-Service
cd rest-service
npm install # Run, if dependencies are not install yet
npm start
```

## API Documentation

### REST-Service: Data Collector

**Endpoint**: `GET /api/data`

**Query Parameters** (one required):

- `first_name` - Filter by user's first name
- `last_name` - Filter by user's last name
- `project_name` - Filter by project name
- `user_id` - Filter by user ID
- `project_id` - Filter by project ID

**Response Format**:

```json
{
  "param": "first_name=John",
  "data": [
    {
      "firstName": "John",
      "lastName": "Johnson",
      "projectName": "Work",
      "date": "2025-01-05",
      "hours": 5.5
    }
  ]
}
```

**Example Requests**:

```bash
# Query by first name
curl "http://localhost:3000/api/data?first_name=John"

# Query by last name
curl "http://localhost:3000/api/data?last_name=Johnson"

# Query by project name
curl "http://localhost:3000/api/data?project_name=Work"

# Query by user ID
curl "http://localhost:3000/api/data?user_id=5"

# Query by project ID
curl "http://localhost:3000/api/data?project_id=2"
```

**Error Responses**:

- `400` - Missing or invalid query parameter
- `404` - Endpoint not found
- `500` - Database error or Service 2 communication failure

### RPC-Service: Data Storage

**Endpoint**: `POST /` (JSON-RPC 2.0)

**Available Methods**:

1. **saveRequestSingle** - Saves all data items in a single row
2. **saveRequestMultiple** - Saves each data item as a separate row (all with same request_id)

**Request Format**:

```json
{
  "jsonrpc": "2.0",
  "method": "saveRequestSingle",
  "params": {
    "param": "first_name=John",
    "data": [
      {
        "firstName": "John",
        "lastName": "Johnson",
        "projectName": "Work",
        "date": "2025-01-05",
        "hours": 5.5
      }
    ]
  },
  "id": "<some_UUID>"
}
```

**Response Format**:

```json
{
  "jsonrpc": "2.0",
  "result": {
    "requestId": "550e8400-e29b-41d4-a716-446655440000",
    "message": "Data saved successfully"
  },
  "id": "<some_UUID>"
}
```

**Example Request**:

```bash
curl -X POST http://localhost:3001 \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "saveRequestSingle",
    "params": {
      "param": "first_name=John",
      "data": [{"firstName":"John","lastName":"Johnson","projectName":"Work","date":"2025-01-05","hours":5.5}]
    },
    "id": "550e8400-e29b-41d4-a716-446655440000"
  }'
```

## How It Works

1. Client sends GET request to REST-Service with a query parameter
2. REST-Service queries the SQL Server database using raw SQL
3. REST-Service formats the results into a standardized JSON structure
4. REST-Service calls RPC-Service via JSON-RPC using the `saveRequestSingle` method
5. RPC-Service stores the data in the Requests table with a unique request_id
6. RPC-Service confirms success back to REST-Service
7. REST-Service returns the data to the client

## Error Handling

- Both services return appropriate HTTP status codes and error messages
- REST-Service waits for RPC-Service confirmation before responding to the client
- If RPC-Service fails, REST-Service returns a 500 error to the client
- All database errors are caught and returned as JSON error responses

## License

MIT
