export type HttpMethod = "GET" | "POST" | "PUT" | "DELETE";

export class ApiEndpoint { 
    controller: string;
    action: string;
    method: HttpMethod;

    constructor(controller: string, action: string, method: HttpMethod) {
        this.controller = controller;
        this.action = action;
        this.method = method;
    }
}

export const getUserDetailsEndpoint = new ApiEndpoint("auth", "teacherDetails", "GET");
export const createAccountEndpoint = new ApiEndpoint("auth", "createTeacherAccount", "POST");
export const getClassesEndpoint = new ApiEndpoint("teacher", "getClasses", "GET");
export const getTasksForClassEndpoint = new ApiEndpoint("teacher", "getTasksForClass", "GET");
export const getProgressForTaskEndpoint = new ApiEndpoint("teacher", "getProgressForTask", "GET");
export const getDecksEndpoint = new ApiEndpoint("teacher", "getDecks", "GET");
export const getCardsForDeckEndpoint = new ApiEndpoint("teacher", "getCardsForDeck", "GET");