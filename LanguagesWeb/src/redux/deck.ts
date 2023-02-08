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
        // Log that the system is currently loading deck details.
        startedLoading: (state) => {
            state.isLoading = true;
            state.deck = null;
            state.cards = null;
            state.changesMade = false;
        },
        // Saves the deck details from the server's response.
        finishedLoading: (state, action: PayloadAction<DeckSummary>) => {
            state.deck = action.payload.deckDetails;
            state.cards = action.payload.cards;
            state.isLoading = false;
            state.changesMade = false;
        },
        // Adds a card to the list to display. Scrolls it into view.
        addCard: (state, action: PayloadAction<Card>) => {
            if (state.cards == null) return;
            state.cards.push(action.payload);
            window.scrollTo(0, document.body.scrollHeight);
        },
        // Replaces an old card with a newer version.
        replaceCard: (state, action: PayloadAction<{ card: Card, replacementCard: Card }>) => {
            let index = state.cards!.indexOf(action.payload.card) ?? -1;
            if (index >= 0) {
                state.cards![index] = action.payload.replacementCard;
            }
        },
        // Removes a card from the list to display.
        removeCard: (state, action: PayloadAction<number>) => {
            state.cards = state.cards?.filter(c => c.cardId !== action.payload) ?? null;
        }
    }
});

export const { startedLoading, finishedLoading, addCard, replaceCard, removeCard } = deckSlice.actions;

// Gets deck details for a given deck from the server.
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

// Deletes a deck from the server, after confirming with the user.
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

// Saves a card to the server. Creates a new card if it doesn't have an ID.
export const saveCard = (card: Card, deck: Deck): TypedThunk => {
    return async (dispatch, getState) => {
        try {
            const token = getState().auth.token || await authService.getToken();
            if (card.cardId !== -1) {
                await endpoints.editCard.makeRequest(token, { deckId: deck.deckId, cardId: card.cardId, englishTerm: card.englishTerm, foreignTerm: card.foreignTerm });
            } else if (card.englishTerm.trim().length !== 0 && card.foreignTerm.trim().length !== 0) {
                const replacementCard = await endpoints.newCard.makeRequest(token, { deckId: deck.deckId, englishTerm: card.englishTerm, foreignTerm: card.foreignTerm });
                dispatch(replaceCard({ card, replacementCard }));
            }
        } catch (error) {
            errorToast(error);
        }
    };
};

// Creates a new card with empty fields.
export const newCard = (deck: Deck): TypedThunk => {
    return async (dispatch, getState) => {
        dispatch(addCard({ cardId: -1, englishTerm: "", foreignTerm: "" }));
    };
};

// Duplicates a card in the deck.
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

// Deletes a card from the server.
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

// Edits the name of the provided deck.
export const editDeckName = (deckId: number, name: string): TypedThunk => {
    return async (dispatch, getState) => {
        if (name.trim().length === 0) {
            errorToast("This deck name is invalid. Please ensure it is not empty.");
            dispatch(loadDeckDetails(deckId)); // Reset name
            return;
        }

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