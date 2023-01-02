import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import authService from "../services/authService";
import { TypedThunk } from "./store";
import { errorToast } from "../helper/toast";
import * as nav from "./nav";
import * as endpoints from "../api/endpoints";

interface NewTaskState {
    showModal: boolean,
    isLoading: boolean,
    classId: number | null,
    deckId: number | null,
    dueDate: number | null,
    classEditable: boolean
}

const initialState: NewTaskState = {
    showModal: false,
    isLoading: false,
    classId: null,
    deckId: null,
    dueDate: null,
    classEditable: true
}

export const newTaskSlice = createSlice({
    name: "newtask",
    initialState,
    reducers: {
        showModal: (state) => {
            state.classId = null;
            state.classEditable = true;
            state.showModal = true;
        },
        showModalForClass: (state, action: PayloadAction<number>) => {
            state.classId = action.payload;
            state.classEditable = false;
            state.showModal = true;
        },
        selectedClass: (state, action: PayloadAction<number | null>) => {
            state.classId = action.payload;
        },
        selectedDeck: (state, action: PayloadAction<number | null>) => {
            state.deckId = action.payload;
        },
        changedDate: (state, action: PayloadAction<number>) => {
            state.dueDate = action.payload;
        },
        startedCreating: (state) => {
            state.isLoading = true;
        },
        finishedCreating: (state) => {
            state.showModal = false;
            state.isLoading = false;
            state.classId = null;
            state.deckId = null;
            state.dueDate = null;
            state.classEditable = true;
        },
        failedCreating: (state) => {
            state.isLoading = false;
        },
        closeModal: (state) => {
            state.showModal = false;
        }
    }
});

export const { showModal, showModalForClass, selectedClass, selectedDeck, changedDate, startedCreating, finishedCreating, failedCreating, closeModal } = newTaskSlice.actions;

/** Gets and saves the classes for the current user. */
export const createNewTask = (): TypedThunk => {
    return async (dispatch, getState): Promise<void> => {
        const { isLoading, classId, deckId, dueDate } = getState().newTask;

        if (classId == null) {
            errorToast("Please select a class.");
            return;
        }

        if (deckId == null) {
            errorToast("Please select a deck.");
            return;
        }

        if (dueDate == null) {
            errorToast("Please select a due date.");
            return;
        }

        if (dueDate < Date.now()) {
            errorToast("Due date must be in the future.");
            return;
        }
        
        if (isLoading) return;
        dispatch(startedCreating());

        try {
            const token = getState().auth.token || await authService.getToken();
            const task = await endpoints.newTask.makeRequest(token, { classId, deckId, dueDate: dueDate });
            
            dispatch(finishedCreating());
            dispatch(nav.openTask(task.id));
        } catch (error) {
            dispatch(failedCreating());
            errorToast(error);
        }
    }
}