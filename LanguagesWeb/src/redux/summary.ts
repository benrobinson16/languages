import { Class, Deck, Task } from "../api/models";
import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import authService from "../services/authService";
import store, { TypedThunk } from "./store";
import { errorToast } from "../helper/toast";
import { getSummary } from "../api/endpoints";

interface SummaryState {
    isLoading: boolean,
    classes: Class[] | null,
    tasks: Task[] | null,
    decks: Deck[] | null
}

const initialState: SummaryState = {
    isLoading: false,
    classes: null,
    tasks: null,
    decks: null
}

export const summarySlice = createSlice({
    name: "summary",
    initialState,
    reducers: {
        startedLoading: (state) => {
            state.isLoading = true;
            state.classes = null;
            state.tasks = null;
            state.decks = null;
        },
        loadedClasses: (state, action: PayloadAction<Class[]>) => {
            state.classes = action.payload;
            state.isLoading = false
        },
        loadedTasks: (state, action: PayloadAction<Task[]>) => {
            state.tasks = action.payload;
            state.isLoading = false
        },
        loadedDecks: (state, action: PayloadAction<Deck[]>) => {
            state.decks = action.payload;
            state.isLoading = false
        },
        failedLoadingSummary: (state) => {
            state.isLoading = false;
        }
    }
});

export const { startedLoading, loadedClasses, loadedTasks, loadedDecks, failedLoadingSummary } = summarySlice.actions;

/** Gets and saves the classes for the current user. */
export const loadSummary = (): TypedThunk => {
    return async (dispatch, getState): Promise<void> => {
        store.dispatch(startedLoading());

        try {
            console.log(getState().auth.token);
            console.log(getState().auth.user);
            const token = getState().auth.token || await authService.getToken();
            const userId = getState().auth.user?.id;

            if (token == null || userId == null) {
                throw new Error("Authentication has failed.");
            }

            const response = await getSummary.makeRequest(token);
            dispatch(loadedClasses(response.classes));
            dispatch(loadedTasks(response.tasks));
            dispatch(loadedDecks(response.decks));
        } catch (error) {
            errorToast(error);
            dispatch(failedLoadingSummary());
        }
    }
}