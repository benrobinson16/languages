// Define the possible HTTP methods for a request, to prevent typos.
export type HttpMethod = "GET" | "POST" | "PUT" | "DELETE" | "PATCH";

// Note that https is required for connecting to the endpoint.
// Asp.net rejects any unencrypted connections transmitting JWTs.
export const baseUrl = "https://localhost:7255";