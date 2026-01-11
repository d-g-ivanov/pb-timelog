import http from "node:http";
import { randomUUID } from "node:crypto";
import { RPC_METHOD, RPC_URI } from "../config";
import { ApiResponse } from "../types";

export async function sendRPC(payload: ApiResponse): Promise<void> {
  return new Promise((resolve, reject) => {
    const serviceUrl = new URL(RPC_URI);
    const jsonRpcRequest = {
      jsonrpc: "2.0",
      method: RPC_METHOD,
      params: payload,
      id: randomUUID(),
    };

    const postData = JSON.stringify(jsonRpcRequest);

    const options = {
      hostname: serviceUrl.hostname,
      port: serviceUrl.port,
      path: serviceUrl.pathname,
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Content-Length": Buffer.byteLength(postData),
      },
    };

    const req = http.request(options, (res) => {
      let data = "";

      res.on("data", (chunk) => {
        data += chunk;
      });

      res.on("end", () => {
        try {
          const response = JSON.parse(data);
          if (response.error) {
            reject(new Error(response.error.message));
          } else {
            resolve(response.result);
          }
        } catch (err) {
          reject(err);
        }
      });
    });

    req.on("error", (err) => {
      reject(err);
    });

    req.write(postData);
    req.end();
  });
}
