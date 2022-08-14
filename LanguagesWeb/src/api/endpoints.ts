import { Teacher, TeacherSummary, Class, Task, TaskSummary, Deck, Card, ClassSummary } from "./models";
import { ApiEndpoint } from "./apiEndpoint";
import { ParameterisedEndpoint } from "./parameterisedEndpoint";

/*

Endpoints are defined centrally here for the following reasons.

- Maintainability. It is easy to see at a glance all the endpoints used by the client, and discern
  the purpose of each one. If the path for one of the endpoints changed, it only needs to be edited here.

- Typo safety. The client application does not need to repeat the path string for each request, so there
  is a single point of truth for the name of each path.

- Type safety. Each endpoint here declares the type of data it expects to send as part of the request
  and the type of the data it expects to be returned from the server. This means that with Typescript the
  correct parameters and return type is enforced at the call site.

*/

// Account/general endpoints.
export const getTeacherDetails = new ApiEndpoint<Teacher>("account", "teacher/details", "GET");
export const registerTeacher = new ParameterisedEndpoint<"title" | "surname", Teacher>("account", "teacher/register", "POST");
export const getSummary = new ApiEndpoint<TeacherSummary>("teacher", "summary", "GET");

// Class endpoints.
export const getClass = new ParameterisedEndpoint<"classId", ClassSummary>("teacher", "class", "GET");
export const newClass = new ParameterisedEndpoint<"name", Class>("teacher", "class", "POST");
export const editClass = new ParameterisedEndpoint<"classId" | "name", Class>("teacher", "class", "PATCH");
export const deleteClass = new ParameterisedEndpoint<"classId", void>("teacher", "class", "DELETE");

// Task endpoints.
export const getTask = new ParameterisedEndpoint<"taskId", TaskSummary>("teacher", "task", "GET");
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

// Notification endpoints.
export const reminderNotification = new ParameterisedEndpoint<"studentId" | "taskId", void>("teacher", "notification/reminder", "POST");
export const congratsNotification = new ParameterisedEndpoint<"studentId" | "taskId", void>("teacher", "notification/congrats", "POST");