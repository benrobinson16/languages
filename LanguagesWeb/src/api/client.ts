import type { User, Task, Class, StudentProgress, Deck, Card } from './models';

interface Client {
    url: string,
    token: string,
    setToken: (token: string) => void,
    makeRequest: (method: HttpMethod, path: string, data?: any) => Promise<any>
    getUserDetails: () => Promise<User>,
    getClasses: () => Promise<Class[]>,
    getTasksForClass: (classId: number) => Promise<Task[]>
    getProgressForTask: (taskId: number) => Promise<StudentProgress[]>,
    getDecks: () => Promise<Deck[]>,
    getCardsForDeck: (deckId: number) => Promise<Card[]>,
}

type HttpMethod = "GET" | "POST" | "PUT" | "DELETE";

export const client: Client = {
    url: 'http://localhost:3000',
    token: "",
    setToken(token: string): void {
        this.token = token;
    },
    makeRequest(method: HttpMethod, path: string, data?: any): Promise<any> {
        let headers = new Headers();
        headers.append("Authorization", this.token);
        headers.append("Content-Type", "application/json");

        let options = {
            method: method,
            headers: headers,
        };

        return fetch(this.url + path, options)
            .then(res => res.json())
            .catch(err => console.log(err));
    },
    async getUserDetails(): Promise<User> {
        let response = await this.makeRequest("GET", "/auth/teacherDetails");
        return response.body as User;
    },
    async getClasses(): Promise<Class[]> {
        let response = await this.makeRequest("GET", "/teacher/getClasses");
        return response.body as Class[];
    },
    async getTasksForClass(classId: number): Promise<Task[]> {
        let response = await this.makeRequest("GET", "/teacher/getTasksForClass", { classId: classId })
        return response.body as Task[];
    },
    async getProgressForTask(taskId: number): Promise<StudentProgress[]> {
        let response = await this.makeRequest("GET", "/teacher/getProgressForTask", { taskId: taskId })
        return response.body as StudentProgress[];
    },
    async getDecks(): Promise<Deck[]> {
        let response = await this.makeRequest("GET", "/teacher/getDecks");
        return response.body as Deck[];
    },
    async getCardsForDeck(deckId: number): Promise<Card[]> {
        let response = await this.makeRequest("GET", "/teacher/getCardsForDeck", { deckId: deckId })
        return response.body as Card[];
    },
}