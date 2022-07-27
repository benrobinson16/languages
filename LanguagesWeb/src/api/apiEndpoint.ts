import { baseUrl, HttpMethod } from "./common";

export class ApiEndpoint<Res> { 
    controller: string;
    action: string;
    method: HttpMethod;

    constructor(controller: string, action: string, method: HttpMethod) {
        this.controller = controller;
        this.action = action;
        this.method = method;
    }

    async makeRequest(token: string): Promise<Res> {
        let headers = new Headers();
        headers.append("Authorization", token);
        headers.append("Content-Type", "application/json");

        let options = {
            method: this.method,
            headers: headers,
        };
        
        let url = new URL(baseUrl + "/" + this.controller + "/" + this.action);

        const response = await fetch(url, options);
        return await response.json();
    }
}