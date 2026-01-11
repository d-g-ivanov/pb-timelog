import sql from "mssql";
import { randomUUID } from "crypto";
import { SaveRequestParams } from "../types";
import { DB_URI } from "../config";

const buildQuery = (
  params: SaveRequestParams,
  requestId: string,
  reqDate: string,
  item: any
) => {
  const dataJson = JSON.stringify(item);
  return `
    INSERT INTO Requests (request_id, req_date, param, data)
    VALUES ('${requestId}', '${reqDate}', '${
    params.param
  }', '${dataJson.replace(/'/g, "''")}')
  `;
};

// Saves the request to a single entry in the database
export async function saveRequestSingle(
  params: SaveRequestParams,
  id?: string
): Promise<string> {
  const pool = await sql.connect(DB_URI);
  const requestId = id ?? randomUUID();
  const reqDate = new Date().toISOString();

  const query = buildQuery(params, requestId, reqDate, params.data);
  await pool.request().query(query);
  await pool.close();

  return requestId;
}

// Saves each object in the data array to its own row in the database
export async function saveRequestMultiple(
  params: SaveRequestParams,
  id?: string
): Promise<string> {
  const pool = await sql.connect(DB_URI);
  const requestId = id ?? randomUUID();
  const reqDate = new Date().toISOString();

  for (const item of params.data) {
    const query = buildQuery(params, requestId, reqDate, item);
    await pool.request().query(query);
  }

  await pool.close();

  return requestId;
}
