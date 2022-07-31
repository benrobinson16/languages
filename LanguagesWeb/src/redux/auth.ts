import { Teacher } from "../api/models";
import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import authService from "../services/authService";
import { AppDispatch, AppState } from "./store";
import * as nav from "./nav";
import { errorToast } from "../helper/toast";

interface AuthState {
    token: string | null,
    user: Teacher | null,
    isAuthenticating: boolean
}

const initialState: AuthState = {
    token: null,
    user: null,
    isAuthenticating: false
}

export const authSlice = createSlice({
    name: "navigation",
    initialState,
    reducers: {
        startedAuthenticating: (state) => {
            state.isAuthenticating = true;
            state.token = null;
            state.user = null;
        },
        gotToken: (state, action: PayloadAction<string>) => {
            state.token = action.payload;
        },
        gotUserInfo: (state, action: PayloadAction<Teacher>) => {
            state.user = action.payload;
            state.isAuthenticating = false;
        },
        encounteredError: (state) => {
            state.isAuthenticating = false;
        }
    }
});

export const { startedAuthenticating, gotToken, gotUserInfo, encounteredError } = authSlice.actions;

/** Gets a token by authenticating with MSAL. Will not redirect so should only be used once the user is signed in. */
export const getToken = (redirectToHome: boolean = false) => {
    return async (dispatch: AppDispatch, getState: () => AppState) => {
        if (getState().auth.isAuthenticating) return;
        dispatch(startedAuthenticating());

        try {
            const token = await authService.getToken();
            dispatch(gotToken(token));

            //const userInfo = await apiService.getUserDetails(token);
            //dispatch(gotUserInfo(userInfo));

            const userInfo: Teacher = {id: 1, title: "Mr.", surname: "Robinson", email: "k037047@eltham-college.org.uk"};
            dispatch(gotUserInfo(userInfo));

            if (redirectToHome) {
                dispatch(nav.openHome());
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
            //const userInfo = apiService.getUserDetails(token);
            const userInfo: Teacher = { id: 0, title: "Mr.", surname: "Smith", email: "smith@example.com" };
            dispatch(gotUserInfo(userInfo));

            dispatch(nav.openHome());
        } catch (error) {
            errorToast(error);
            dispatch(encounteredError());
        }
    };
}