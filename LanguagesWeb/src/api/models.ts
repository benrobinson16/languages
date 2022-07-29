/*
Declare models expected as return types from the API. Note that these
do not neccessarily correspond to the models in the database as the
server may return a ViewModel datatype.
*/

export interface Teacher {
    id: number,
    title: string,
    surname: string,
    email: string
}

export interface Student { 
    id: number,
    firstName: string,
    surname: String,
    email: string
}

export interface Card {
    id: number,
    englishTerm: string,
    foreignTerm: string,
    difficulty: number
}

export interface StudentProgress {
    studentId: number,
    progress: number
}

export interface Task {
    id: number,
    dueDate: Date,
    deckId: number,
    studentsComplete: number,
    className: string,
    deckName: string,
}

export interface Deck {
    id: number,
    name: string,
    cards: Card[],
    dateModified: Date
}

export interface Class {
    id: number,
    name: string,
    numActiveTasks: number,
    numStudents: number
}

export interface TeacherSummary {
    classes: Class[],
    tasks: Task[],
    decks: Deck[]
}