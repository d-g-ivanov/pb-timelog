import http from "node:http";
import { getBody } from "./helpers";
import { saveRequestMultiple, saveRequestSingle } from "./services/DBService";

const RemoteProcedures: Record<string, Function> = {
  saveRequestSingle,
  saveRequestMultiple,
};

export const rpcHanlder = async (
  req: http.IncomingMessage,
  res: http.ServerResponse
) => {
  // Extract the body
  const body: string = await getBody(req);

  // Parse JSON-RPC request
  const jsonRpcRequest = JSON.parse(body);
  if (jsonRpcRequest.jsonrpc !== "2.0") {
    res.writeHead(400, { "Content-Type": "application/json" });
    res.end(
      JSON.stringify({
        jsonrpc: "2.0",
        error: { code: -32600, message: "Invalid Request" },
        id: jsonRpcRequest.id,
      })
    );
    return;
  }

  // Find the requested method
  const fn = RemoteProcedures[jsonRpcRequest.method];
  if (!fn) {
    res.writeHead(404, { "Content-Type": "application/json" });
    res.end(
      JSON.stringify({
        jsonrpc: "2.0",
        error: { code: -32601, message: "Method not found" },
        id: jsonRpcRequest.id,
      })
    );
    return;
  }

  // Call the method with parameters and respond back
  // if this rejects / throws, main handler in index.ts will catch it
  const result = await fn(jsonRpcRequest.params, jsonRpcRequest.id);
  res.writeHead(200, { "Content-Type": "application/json" });
  res.end(
    JSON.stringify({
      jsonrpc: "2.0",
      result: { requestId: result, message: "Data saved successfully" },
      id: jsonRpcRequest.id,
    })
  );
};
