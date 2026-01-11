import http from "node:http";
import { URL } from "node:url";
import { PORT } from "./config";
import { ApiResponse, IRouter } from "./types";
import { queryDatabase } from "./services/DBQueryService";
import { sendRPC } from "./services/RpcService";

// This can be further broken down into separate route files if needed
const dataGetController = async (
  req: http.IncomingMessage,
  res: http.ServerResponse
) => {
  // Parse query parameters
  const url = new URL(req.url!, `http://localhost:${PORT}`);
  const params = url.searchParams;

  // Find which parameter was provided
  const validParams = [
    "first_name",
    "last_name",
    "project_name",
    "user_id",
    "project_id",
  ];
  let paramName = "";
  let paramValue = "";

  for (const param of validParams) {
    if (params.has(param)) {
      paramName = param;
      paramValue = params.get(param)!;
      break;
    }
  }

  if (!paramName) {
    res.writeHead(400, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ error: "Missing valid query parameter" }));
    return;
  }

  // Query database
  const data = await queryDatabase(paramName, paramValue);

  const response: ApiResponse = {
    param: `${paramName}=${paramValue}`,
    data,
  };

  // Send to RPC-Service
  // if it fails, or RPC-Service returns an error, function rejects
  // main app handler in index.ts will catch and respond with 500
  await sendRPC(response);

  // Return success response
  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(JSON.stringify(response));
};

const Router: IRouter = {
  GET: {
    "/api/data": dataGetController,
  },
  // Additional methods and routes can be added here
};

export default Router;
