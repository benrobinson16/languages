import { createSlice, PayloadAction } from "@reduxjs/toolkit";

interface NavPage {
    id: "home" | "class" | "deck" | "task" | "signup",
    data: number | null
}

interface NavigationState {
    navStack: NavPage[]
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
        openClass: (state, action: PayloadAction<number>) => {
            state.navStack.push({ id: "class", data: action.payload });
        },
        openDeck: (state, action: PayloadAction<number>) => {
            state.navStack.push({ id: "deck", data: action.payload });
        },
        openTask: (state, action: PayloadAction<number>) => {
            state.navStack.push({ id: "task", data: action.payload });
        },
        back: (state) => {
            // Only proceed if there is something to pop.
            if (state.navStack.length === 0) return
            
            // Pop the current page, provided it is not the home page.
            if (state.navStack[state.navStack.length - 1].id !== "home") {
                state.navStack.pop();
            }
        },
        popToHome: (state) => {
            state.navStack = [{ id: "home", data: null }];
        }
    }
});

export const { openHome, openSignUp, openClass, openDeck, openTask, back, popToHome } = navSlice.actions;