import { baseUrl, HttpMethod } from "./common";

/*

Parameterised Endpoint.

The generic Keys type is a union Typescript type that gives the type system information
about the keys to be expected for the request. Typescript will not allow any requests
with more or fewer parameters to be sent.

The generic Res type is the expected result type of the endpoint, avoiding the need
for explicit type casting at the call site.

*/

export class ParameterisedEndpoint<Keys extends string, Res> { 
    controller: string;
    action: string;
    method: HttpMethod;

    constructor(controller: string, action: string, method: HttpMethod) {
        this.controller = controller;
        this.action = action;
        this.method = method;
    }

    // Makes a request to the server and waits for an empty response.
    async makeRequestVoid(token: string, data: Record<Keys, string | number>) {
        let headers = new Headers();
        headers.append("Authorization", token);
        headers.append("Content-Type", "application/json");

        let options = {
            method: this.method,
            headers: headers,
        };
        
        let url = new URL(baseUrl + "/" + this.controller + "/" + this.action);

        for (const key of Object.keys(data)) {
            url.searchParams.append(key, data[key as Keys].toString());
        }

        await fetch(url, options);
    }

    // Makes a request to the server and returns the result as a promise.
    async makeRequest(token: string, data: Record<Keys, string | number>): Promise<Res> {
        let headers = new Headers();
        headers.append("Authorization", token);
        headers.append("Content-Type", "application/json");

        let options = {
            method: this.method,
            headers: headers,
        };
        
        let url = new URL(baseUrl + "/" + this.controller + "/" + this.action);

        for (const key of Object.keys(data)) {
            url.searchParams.append(key, data[key as Keys].toString());
        }

        const response = await fetch(url, options);
        return await response.json();
    }
}