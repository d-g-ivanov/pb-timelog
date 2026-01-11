import http from "node:http";

export interface DataResponse {
  firstName: string;
  lastName: string;
  projectName: string;
  date: string;
  hours: number;
}

export interface ApiResponse {
  param: string;
  data: DataResponse[];
}

export type HTTPMethod =
  | "GET"
  | "POST"
  | "PUT"
  | "DELETE"
  | "PATCH"
  | "OPTIONS"
  | "HEAD";

export type IRouter = {
  [method in HTTPMethod]?: {
    [path: string]: (
      req: http.IncomingMessage,
      res: http.ServerResponse
    ) => Promise<void>;
  };
};
