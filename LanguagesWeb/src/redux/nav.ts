import { Deck, Class, Task } from "../api/models";
import { createSlice, PayloadAction } from "@reduxjs/toolkit";

interface NavPage {
    id: "home" | "classes" | "class" | "decks" | "deck" | "tasks" | "task" | "signup",
    data: number | null
}

interface NavigationState {
    navStack: NavPage[],
}

const initialState: NavigationState = {
    navStack: []
}

export const navSlice = createSlice({
    name: "navigation",
    initialState,
    reducers: {
        openHome: (state) => {
            state.navStack.push({ id: "home", data: null });
        },
        openSignUp: (state) => {
            state.navStack.push({ id: "signup", data: null });
        },
        openClassList: (state) => {
            state.navStack.push({ id: "classes", data: null });
        },
        openClass: (state, action: PayloadAction<number>) => {
            state.navStack.push({ id: "class", data: action.payload });
        },
        openDeckList: (state) => {
            state.navStack.push({ id: "decks", data: null });
        },
        openDeck: (state, action: PayloadAction<number>) => {
            state.navStack.push({ id: "deck", data: action.payload });
        },
        openTaskList: (state) => {
            state.navStack.push({ id: "tasks", data: null });
        },
        openTask: (state, action: PayloadAction<number>) => {
            state.navStack.push({ id: "task", data: action.payload });
        },
        back: (state) => {
            state.navStack.pop();
        }
    }
});

export const { openHome, openSignUp, openClassList, openClass, openDeckList, openDeck, openTaskList, openTask, back } = navSlice.actions;