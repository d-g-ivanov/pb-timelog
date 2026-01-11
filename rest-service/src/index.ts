import http from "node:http";
import { PORT, SERVICE_NAME } from "./config";
import { HTTPMethod } from "./types";
import Router from "./Router";

const server = http.createServer(
  async (req: http.IncomingMessage, res: http.ServerResponse) => {
    const method = req.method as HTTPMethod;
    const url = req.url?.split("?")[0] || "/";
    const handler = Router[method]?.[url];

    if (handler) {
      try {
        await handler(req, res);
      } catch (error) {
        console.error("Error:", error);
        res.writeHead(500, { "Content-Type": "application/json" });
        res.end(
          JSON.stringify({
            error:
              error instanceof Error
                ? error.message || "Internal server error"
                : "Internal server error",
          })
        );
      }
    } else {
      res.writeHead(404, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ error: "Not found" }));
    }
  }
);

server.listen(PORT, () => {
  console.log(`${SERVICE_NAME} running on port ${PORT}`);
});
