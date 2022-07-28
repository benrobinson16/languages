import { Teacher, TeacherSummary, Class, Task, Deck, Card } from "./models";
import { ApiEndpoint } from "./apiEndpoint";
import { ParameterisedEndpoint } from "./parameterisedEndpoint";

// General endpoints.
export const getTeacherDetails = new ApiEndpoint<Teacher>("teacher", "getDetails", "GET");
export const registerTeacher = new ParameterisedEndpoint<"title" | "surname", Teacher>("teacher", "register", "POST");
export const getSummary = new ApiEndpoint<TeacherSummary>("teacher", "summary", "GET");

// Class endpoints.
export const getClass = new ParameterisedEndpoint<"classId", Class>("teacher", "class", "GET");
export const newClass = new ParameterisedEndpoint<"name", Class>("teacher", "class", "POST");
export const updateClass = new ParameterisedEndpoint<"classId" | "name", Class>("teacher", "class", "PATCH");
export const deleteClass = new ParameterisedEndpoint<"classId", void>("teacher", "class", "DELETE");

// Task endpoints.
export const getTask = new ParameterisedEndpoint<"taskId", Task>("teacher", "task", "GET");
export const newTask = new ParameterisedEndpoint<"classId" | "deckId" | "dueDate", Task>("teacher", "task", "POST");
export const editTask = new ParameterisedEndpoint<"taskId" | "classId" | "deckId" | "dueDate", Task>("teacher", "task", "PATCH");
export const deleteTask = new ParameterisedEndpoint<"taskId", void>("teacher", "task", "DELETE");

// Deck endpoints.
export const getDeck = new ParameterisedEndpoint<"taskId", Deck>("teacher", "deck", "GET");
export const newDeck = new ParameterisedEndpoint<"name", Deck>("teacher", "deck", "POST");
export const editDeck = new ParameterisedEndpoint<"deckId" | "name", Deck>("teacher", "deck", "PATCH");
export const deleteDeck = new ParameterisedEndpoint<"deckId", void>("teacher", "deck", "DELETE");

// Card endpoints.
export const getCard = new ParameterisedEndpoint<"cardId", Card>("teacher", "card", "GET");
export const newCard = new ParameterisedEndpoint<"deckId" | "englishTerm" | "foreignTerm", Card>("teacher", "card", "POST");
export const editCard = new ParameterisedEndpoint<"cardId" | "deckId" | "englishTerm" | "foreignTerm", Card>("teacher", "card", "PATCH");
export const deleteCard = new ParameterisedEndpoint<"cardId", void>("teacher", "card", "DELETE");