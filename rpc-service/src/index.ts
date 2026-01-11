import http from "http";
import { PORT, SERVICE_NAME } from "./config";
import { rpcHanlder } from "./rpcHandler";

const server = http.createServer(async (req, res) => {
  if (req.method === "POST") {
    try {
      await rpcHanlder(req, res);
    } catch (error) {
      console.error("Error:", error);
      res.writeHead(500, { "Content-Type": "application/json" });
      res.end(
        JSON.stringify({
          jsonrpc: "2.0",
          error: {
            code: -32603,
            message: error instanceof Error ? error.message : "Internal error",
          },
          id: null,
        })
      );
    }
  } else {
    res.writeHead(405, { "Content-Type": "application/json" });
    res.end(
      JSON.stringify({
        jsonrpc: "2.0",
        error: { code: -32601, message: "Method not allowed" },
        id: null,
      })
    );
  }
});

server.listen(PORT, () => {
  console.log(`${SERVICE_NAME} running on port ${PORT}`);
});
