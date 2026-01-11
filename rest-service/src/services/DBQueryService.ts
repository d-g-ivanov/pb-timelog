import sql from "mssql";
import { DataResponse } from "../types";
import { DB_URI } from "../config";

const QueryBuilder: Record<string, (value: string) => string> = {
  first_name: (
    value: string
  ) => `SELECT DISTINCT u.first_name as firstName, u.last_name as lastName, 
             p.project_name as projectName, tl.date, tl.hours
      FROM [User] u
      JOIN TimeLog tl ON u.id = tl.user_id
      JOIN Project p ON tl.project_id = p.id
      WHERE u.first_name = '${value}'
      ORDER BY tl.date`,
  last_name: (
    value: string
  ) => `SELECT DISTINCT u.first_name as firstName, u.last_name as lastName, 
             p.project_name as projectName, tl.date, tl.hours
      FROM [User] u
      JOIN TimeLog tl ON u.id = tl.user_id
      JOIN Project p ON tl.project_id = p.id
      WHERE u.last_name = '${value}'
      ORDER BY tl.date`,
  project_name: (value: string) => `
      SELECT u.first_name as firstName, u.last_name as lastName, 
             p.project_name as projectName, tl.date, tl.hours
      FROM Project p
      JOIN TimeLog tl ON p.id = tl.project_id
      JOIN [User] u ON tl.user_id = u.id
      WHERE p.project_name = '${value}'
      ORDER BY tl.date`,
  user_id: (value: string) => `
      SELECT u.first_name as firstName, u.last_name as lastName, 
             p.project_name as projectName, tl.date, tl.hours
      FROM [User] u
      JOIN TimeLog tl ON u.id = tl.user_id
      JOIN Project p ON tl.project_id = p.id
      WHERE u.id = '${value}'
      ORDER BY tl.date`,
  project_id: (value: string) => `
      SELECT u.first_name as firstName, u.last_name as lastName, 
             p.project_name as projectName, tl.date, tl.hours
      FROM Project p
      JOIN TimeLog tl ON p.id = tl.project_id
      JOIN [User] u ON tl.user_id = u.id
      WHERE p.id = '${value}'
      ORDER BY tl.date`,
};

export async function queryDatabase(
  paramName: string,
  paramValue: string
): Promise<DataResponse[]> {
  const query = QueryBuilder[paramName]?.(paramValue);
  if (!query) throw new Error(`Invalid parameter: ${paramName}`);
  const pool = await sql.connect(DB_URI);
  const result = await pool.request().query(query);
  await pool.close();

  return result.recordset.map((row) => ({
    firstName: row.firstName,
    lastName: row.lastName,
    projectName: row.projectName,
    date: row.date.toISOString().split("T")[0], // maybe keeping as ISO is ok?
    hours: row.hours,
  }));
}
