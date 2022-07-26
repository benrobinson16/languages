import { baseUrl } from "../api/constants";
import { ApiEndpoint, getCardsForDeckEndpoint, getClassesEndpoint, getDecksEndpoint, getTasksForClassEndpoint, getUserDetailsEndpoint } from "../api/endpoints";
import { Teacher, Class, Task, StudentProgress, Deck, Card } from "../api/models";

class ApiService {
    private async makeRequest(token: string, endpoint: ApiEndpoint, data: { [key: string]: string } = {}): Promise<any> {
        let headers = new Headers();
        headers.append("Authorization", token);
        headers.append("Content-Type", "application/json");

        let options = {
            method: endpoint.method,
            headers: headers,
        };
        
        let url = new URL(baseUrl + "/" + endpoint.controller + "/" + endpoint.action);
        for (let key in data) {
            url.searchParams.append(key, data[key]);
        }

        try {
            const response = await fetch(url, options);
            return await response.json();
        } catch (error) {
            console.log(error);
            throw error;
        }
    }

    async getUserDetails(token: string): Promise<Teacher> {
        return await this.makeRequest(token, getUserDetailsEndpoint);
    }

    async getClasses(token: string, userId: number): Promise<Class[]> {
        return await this.makeRequest(token, getClassesEndpoint, { "userId": userId.toString() });
    }

    async getTasksForClass(token: string, classId: number): Promise<Task[]> {
        return await this.makeRequest(token, getTasksForClassEndpoint, { "classId": classId.toString() });
    }
    
    async getProgressForTask(token: string, taskId: number): Promise<StudentProgress[]> {
        return await this.makeRequest(token, getClassesEndpoint, { "taskId": taskId.toString() });
    }

    async getDecks(token: string): Promise<Deck[]> {
        return await this.makeRequest(token, getDecksEndpoint);
    }

    async getCardsForDeck(token: string, deckId: number): Promise<Card[]> {
        return await this.makeRequest(token, getCardsForDeckEndpoint, { "deckId": deckId.toString() });
    }
}

export default new ApiService();