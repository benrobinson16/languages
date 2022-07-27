import { Class } from "../api/models";
import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import authService from "../services/authService";
import store, { TypedThunk } from "./store";
import apiService from "../services/apiService";

interface ClassesState {
    isLoading: boolean,
    classes: Class[] | null,
    errorMessage: string | null
}

const initialState: ClassesState = {
    isLoading: false,
    classes: null,
    errorMessage: null
}

export const classesSlice = createSlice({
    name: "classes",
    initialState,
    reducers: {
        startedLoading: (state) => {
            state.isLoading = true;
            state.classes = null;
        },
        loadedClasses: (state, action: PayloadAction<Class[]>) => {
            state.classes = action.payload;
            state.isLoading = false
        },
        failedLoadingClasses: (state, action: PayloadAction<string | null>) => {
            state.errorMessage = action.payload ?? "An unknown error ocurred. Please try again.";
            state.isLoading = false;
        }
    }
});

export const { startedLoading, loadedClasses, failedLoadingClasses } = classesSlice.actions;

export const loadClasses = (): TypedThunk => {
    return async (dispatch, getState): Promise<void> => {
        store.dispatch(startedLoading());

        try {
            const token = getState().auth.token || await authService.getToken();
            const userId = getState().auth.user?.id;

            if (!token || !userId) {
                throw new Error("Authentication has failed.");
            }

            const response: Class[] = await apiService.getClasses(token, userId)
            dispatch(loadedClasses(response));
        } catch (error) {
            if (error instanceof Error) {
                dispatch(failedLoadingClasses(error.message));
            } else if (typeof error === "string") {
                dispatch(failedLoadingClasses(error));
            } else {
                dispatch(failedLoadingClasses("An unexpected error was encountered. Please try again."));
            }
        }
    }
}