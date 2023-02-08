import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import authService from "../services/authService";
import { TypedThunk } from "./store";
import { errorToast } from "../helper/toast";
import * as nav from "./nav";
import * as endpoints from "../api/endpoints";

interface NewDeckState {
    showModal: boolean,
    isLoading: boolean,
    name: string
}

const initialState: NewDeckState = {
    showModal: false,
    isLoading: false,
    name: ""
}

export const newDeckSlice = createSlice({
    name: "newdeck",
    initialState,
    reducers: {
        // Opens the modal to create a new deck.
        showModal: (state) => {
            state.showModal = true;
        },
        // Change the displayed deck name.
        nameChange: (state, action: PayloadAction<string>) => {
            state.name = action.payload;
        },
        // Log that the system is currently creating a new deck.
        startedCreating: (state) => {
            state.isLoading = true;
        },
        // Log that the system has finished creating a new deck.
        finishedCreating: (state) => {
            state.showModal = false;
            state.isLoading = false;
            state.name = "";
        },
        // Log that the system has failed to create a deck.
        failedCreating: (state) => {
            state.isLoading = false;
        },
        // Close the new deck modal.
        closeModal: (state) => {
            state.showModal = false;
        }
    }
});

export const { showModal, nameChange, startedCreating, finishedCreating, failedCreating, closeModal } = newDeckSlice.actions;

// Gets and saves the classes for the current user.
export const createNewDeck = (): TypedThunk => {
    return async (dispatch, getState): Promise<void> => {
        const name = getState().newDeck.name;
        const isLoading = getState().newDeck.isLoading;

        if (isLoading) return;
        dispatch(startedCreating());

        if (name.trim().length === 0) {
            dispatch(failedCreating());
            errorToast("Please enter a name for the deck.");
            return;
        }

        try {
            const token = getState().auth.token || await authService.getToken();
            const deck = await endpoints.newDeck.makeRequest(token, { name: name });

            dispatch(finishedCreating());
            dispatch(nav.openDeck(deck.deckId));
        } catch (error) {
            dispatch(failedCreating());
            errorToast(error);
        }
    }
}