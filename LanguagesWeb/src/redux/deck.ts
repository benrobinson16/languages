import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import authService from "../services/authService";
import { TypedThunk } from "./store";
import { errorToast, successToast, toast } from "../helper/toast";
import * as endpoints from "../api/endpoints";
import { Card, Deck, DeckSummary, StudentProgress, Task, TaskSummary } from "../api/models";

interface DeckState {
    isLoading: boolean,
    deck: Deck | null,
    cards: Card[] | null,
    isSaving: boolean,
    changesMade: boolean
}

const initialState: DeckState = {
    isLoading: false,
    deck: null,
    cards: null,
    isSaving: false,
    changesMade: false
}

export const deckSlice = createSlice({
    name: "deck",
    initialState,
    reducers: {
        startedLoading: (state) => {
            state.isLoading = true;
            state.deck = null;
            state.cards = null;
            state.isSaving = false;
            state.changesMade = false;
        },
        finishedLoading: (state, action: PayloadAction<DeckSummary>) => {
            state.deck = action.payload.deckDetails;
            state.cards = action.payload.cards;
            state.isLoading = false;
            state.isSaving = false;
            state.changesMade = false;
        },
        editedCard: (state, action: PayloadAction<{ index: number, card: Card }>) => {
            if (state.cards == null || state.cards.length <= action.payload.index) return;
            state.cards[0].englishTerm = action.payload.card.englishTerm;
            state.cards[0].foreignTerm = action.payload.card.foreignTerm;
            state.changesMade = true;
        },
        addCard: (state, action: PayloadAction<Card>) => {
            if (state.cards == null) return;
            var newArr = state.cards.slice();
            newArr.unshift(action.payload);
            state.cards = newArr;
        },
        startedSaving: (state) => {
            state.isSaving = true;
        },
        finishedSaving: (state) => {
            state.isSaving = false;
            state.changesMade = false;
        },
        failedSaving: (state) => {
            state.isSaving = false;
        }
    }
});

export const { startedLoading, finishedLoading, editedCard, addCard, startedSaving, finishedSaving, failedSaving } = deckSlice.actions;

export const loadDeckDetails = (deckId: number): TypedThunk => {
    return async (dispatch, getState) => {
        dispatch(startedLoading());

        try {
            const token = getState().auth.token || await authService.getToken();
            const response = await endpoints.getDeck.makeRequest(token, { deckId })
            dispatch(finishedLoading(response))
        } catch (error) {
            errorToast(error);
        }
    };
};

export const saveCard = (card: Card, deck: Deck): TypedThunk => {
    return async (dispatch, getState) => {
        dispatch(startedSaving());

        try {
            const token = getState().auth.token || await authService.getToken();
            console.log({ deckId: deck.deckId, cardId: card.cardId, englishTerm: card.englishTerm, foreignTerm: card.foreignTerm });
            await endpoints.editCard.makeRequest(token, { deckId: deck.deckId, cardId: card.cardId, englishTerm: card.englishTerm, foreignTerm: card.foreignTerm });
            dispatch(finishedSaving());
        } catch (error) {
            errorToast(error);
            dispatch(failedSaving());
        }
    };
};

export const newCard = (deck: Deck): TypedThunk => {
    return async (dispatch, getState) => {
        try {
            const token = getState().auth.token || await authService.getToken();
            const card = await endpoints.newCard.makeRequest(token, { deckId: deck.deckId, englishTerm: "", foreignTerm: "" });
            dispatch(addCard(card));
        } catch (error) {
            errorToast(error);
        }
    };
};

export const saveDeckName = (deck: Deck): TypedThunk => {
    return async (dispatch, getState) => {
        dispatch(startedSaving());

        try {
            const token = getState().auth.token || await authService.getToken();
            await endpoints.editDeck.makeRequest(token, { deckId: deck.deckId, name: deck.name });
            dispatch(finishedSaving());
        } catch (error) {
            errorToast(error);
            dispatch(failedSaving());
        }
    };
};
