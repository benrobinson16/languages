import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import authService from "../services/authService";
import { TypedThunk } from "./store";
import { errorToast, successToast } from "../helper/toast";
import * as nav from "./nav";
import * as endpoints from "../api/endpoints";
import { Card, Deck, DeckSummary } from "../api/models";

interface DeckState {
    isLoading: boolean,
    deck: Deck | null,
    cards: Card[] | null,
    changesMade: boolean
}

const initialState: DeckState = {
    isLoading: false,
    deck: null,
    cards: null,
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
            state.changesMade = false;
        },
        finishedLoading: (state, action: PayloadAction<DeckSummary>) => {
            state.deck = action.payload.deckDetails;
            state.cards = action.payload.cards;
            state.isLoading = false;
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
            state.cards.push(action.payload);
            window.scrollTo(0, document.body.scrollHeight);
        },
        removeCard: (state, action: PayloadAction<number>) => {
            state.cards = state.cards?.filter(c => c.cardId !== action.payload) ?? null;
        }
    }
});

export const { startedLoading, finishedLoading, editedCard, addCard, removeCard } = deckSlice.actions;

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

export const deleteDeck = (deckId: number): TypedThunk => {
    return async (dispatch, getState) => {
        const deleteText = "Are you sure you would like to delete this deck? All tasks associated with this deck will be deleted as well.";
        const confirmed = window.confirm(deleteText);

        if (confirmed) {
            try {
                const token = getState().auth.token || await authService.getToken();
                await endpoints.deleteDeck.makeRequestVoid(token, { deckId });
                dispatch(nav.back());
                successToast("Deck deleted.");
            } catch (error) {
                errorToast(error);
            }
        }
    }
}

export const saveCard = (card: Card, deck: Deck): TypedThunk => {
    return async (dispatch, getState) => {
        try {
            const token = getState().auth.token || await authService.getToken();
            await endpoints.editCard.makeRequest(token, { deckId: deck.deckId, cardId: card.cardId, englishTerm: card.englishTerm, foreignTerm: card.foreignTerm });
        } catch (error) {
            errorToast(error);
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

export const copyCard = (card: Card, deck: Deck): TypedThunk => {
    return async (dispatch, getState) => {
        try {
            const token = getState().auth.token || await authService.getToken();
            const newCard = await endpoints.newCard.makeRequest(token, { deckId: deck.deckId, englishTerm: card.englishTerm, foreignTerm: card.foreignTerm });
            dispatch(addCard(newCard));
        } catch (error) {
            errorToast(error);
        }
    };
};

export const deleteCard = (cardId: number): TypedThunk => {
    return async (dispatch, getState) => {
        try {
            const token = getState().auth.token || await authService.getToken();
            await endpoints.deleteCard.makeRequest(token, { cardId });
            dispatch(removeCard(cardId));
        } catch (error) {
            errorToast(error);
        }
    };
};

export const editDeckName = (deckId: number, name: string): TypedThunk => {
    return async (dispatch, getState) => {
        try {
            const token = getState().auth.token || await authService.getToken();
            await endpoints.editDeck.makeRequest(token, { deckId, name });
            successToast("Deck name updated.");
        } catch (error) {
            errorToast(error);
            dispatch(loadDeckDetails(deckId)); // Reset name
        }
    };
};