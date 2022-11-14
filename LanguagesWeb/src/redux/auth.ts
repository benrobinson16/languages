import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import authService from "../services/authService";
import { AppDispatch, AppState } from "./store";
import * as nav from "./nav";
import * as signUp from "./signUp";
import { errorToast } from "../helper/toast";
import { teacherIsNew } from "../api/endpoints";

interface AuthState {
    token: string | null,
    isAuthenticating: boolean
}

const initialState: AuthState = {
    token: null,
    isAuthenticating: false
}

export const authSlice = createSlice({
    name: "navigation",
    initialState,
    reducers: {
        startedAuthenticating: (state) => {
            state.isAuthenticating = true;
            state.token = null;
        },
        gotToken: (state, action: PayloadAction<string>) => {
            state.token = action.payload;
        },
        finishedAuthenticating: (state) => {
            state.isAuthenticating = false;
        },
        encounteredError: (state) => {
            state.isAuthenticating = false;
        }
    }
});

export const { startedAuthenticating, gotToken, finishedAuthenticating, encounteredError } = authSlice.actions;

/** Gets a token by authenticating with MSAL. Will not redirect so should only be used once the user is signed in. */
export const getToken = (redirectToHome: boolean = false) => {
    return async (dispatch: AppDispatch, getState: () => AppState) => {
        if (getState().auth.isAuthenticating) return;
        dispatch(startedAuthenticating());

        try {
            const token = await authService.getToken();
            dispatch(gotToken(token));

            const isNew = await teacherIsNew.makeRequest(token);
            dispatch(finishedAuthenticating());

            if (!isNew && redirectToHome) {
                dispatch(nav.openHome());
            } else if (isNew) {
                dispatch(signUp.showSignUp());
            }
        } catch (error) {
            errorToast(error);
            dispatch(encounteredError());
        }
    }
}

/** Logs a user in via MSAL redirection. */
export const logIn = () => {
    return async (dispatch: AppDispatch, getState: () => AppState) => {
        if (getState().auth.isAuthenticating) return;
        dispatch(startedAuthenticating());

        try {
            await authService.logIn();
        } catch (error) {
            errorToast(error);
            dispatch(encounteredError());
        }
    }
}

/** Responds to a login redirect by saving the response token, obtaining user details and redirecting to home screen. */
export const saveTokenAndRedirect = (token: string) => {
    return async (dispatch: AppDispatch, getState: () => AppState) => {
        dispatch(startedAuthenticating());
        dispatch(gotToken(token));

        try {
            const isNew = await teacherIsNew.makeRequest(token);
            dispatch(finishedAuthenticating());

            if (!isNew) {
                dispatch(nav.openHome());
            } else {
                dispatch(signUp.showSignUp());
            }
        } catch (error) {
            errorToast(error);
            dispatch(encounteredError());
        }
    };
}