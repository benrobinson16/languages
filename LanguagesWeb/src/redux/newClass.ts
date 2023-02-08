import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import authService from "../services/authService";
import { TypedThunk } from "./store";
import { errorToast } from "../helper/toast";
import * as nav from "./nav";
import * as endpoints from "../api/endpoints";

interface NewClassState {
    showModal: boolean,
    isLoading: boolean,
    name: string
}

const initialState: NewClassState = {
    showModal: false,
    isLoading: false,
    name: ""
}

export const newClassSlice = createSlice({
    name: "newclass",
    initialState,
    reducers: {
        // Opens the modal to create a new class.
        showNewClassModal: (state) => {
            state.showModal = true;
        },
        // Changes the name of the class to display.
        nameChange: (state, action: PayloadAction<string>) => {
            state.name = action.payload;
        },
        // Log that the system is currently creating a new class.
        startedCreating: (state) => {
            state.isLoading = true;
        },
        // Log that the system has finished creating a new class.
        finishedCreating: (state) => {
            state.showModal = false;
            state.isLoading = false;
            state.name = "";
        },
        // Log that the system has failed to create a class.
        failedCreating: (state) => {
            state.isLoading = false;
        },
        // Close the new class modal.
        closeModal: (state) => {
            state.showModal = false;
        }
    }
});

export const { showNewClassModal, nameChange, startedCreating, finishedCreating, failedCreating, closeModal } = newClassSlice.actions;

// Gets and saves the classes for the current user.
export const createNewClass = (): TypedThunk => {
    return async (dispatch, getState): Promise<void> => {
        const name = getState().newClass.name;
        const isLoading = getState().newClass.isLoading;

        if (isLoading) return;
        dispatch(startedCreating());

        if (name.trim().length === 0) {
            dispatch(failedCreating());
            errorToast("Please enter a name for the class.");
            return;
        }

        try {
            const token = getState().auth.token || await authService.getToken();
            const cla = await endpoints.newClass.makeRequest(token, { name: name });

            dispatch(finishedCreating());
            dispatch(nav.openClass(cla.id));
        } catch (error) {
            dispatch(failedCreating());
            errorToast(error);
        }
    }
}