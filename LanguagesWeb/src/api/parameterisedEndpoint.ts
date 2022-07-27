import { baseUrl, HttpMethod } from "./common";

export class ParameterisedEndpoint<Keys extends string, Res> { 
    controller: string;
    action: string;
    method: HttpMethod;

    constructor(controller: string, action: string, method: HttpMethod) {
        this.controller = controller;
        this.action = action;
        this.method = method;
    }

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