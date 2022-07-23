export interface User {
    title: string,
    surname: string,
    email: string
}

export interface Card {
    id: number,
    englishTerm: string,
    foreignTerm: string,
    difficulty: number
}

export interface StudentProgress {
    id: number,
    firstName: string,
    surname: string,
    email: string,
    progress: number
}

export interface Task {
    id: number,
    dueDate: Date,
    deckId: number,
    studentsComplete: number
}

export interface Deck {
    id: number,
    name: string,
    cards: Card[]
}

export interface Class {
    id: number,
    name: string
}