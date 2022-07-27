import { Teacher } from "../api/models";
import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import authService from "../services/authService";
import apiService from "../services/apiService";
import { AppDispatch, AppState } from "./store";
import { openHome } from "./nav";

interface AuthState {
    token: string | null,
    user: Teacher | null,
    error: string | null,
    isAuthenticating: boolean
}

const initialState: AuthState = {
    token: null,
    user: null,
    error: null,
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
            state.error = null;
        },
        gotToken: (state, action: PayloadAction<string>) => {
            state.token = action.payload;
        },
        gotUserInfo: (state, action: PayloadAction<Teacher>) => {
            state.user = action.payload;
            state.isAuthenticating = false;
        },
        encounteredError: (state, action: PayloadAction<string>) => {
            state.error = action.payload;
            state.isAuthenticating = false;
        }
    }
});

export const { startedAuthenticating, gotToken, gotUserInfo, encounteredError } = authSlice.actions;

export const getToken = (redirect: boolean = true) => { 
    return async (dispatch: AppDispatch, getState: () => AppState) => {
        if (getState().auth.isAuthenticating) {
            console.log("Already authenticating...");
            return;
        }

        dispatch(startedAuthenticating());

        try {
            const token = await authService.getToken();
            dispatch(gotToken(token));
            const userInfo = await apiService.getUserDetails(token);
            dispatch(gotUserInfo(userInfo));

            if (redirect) {
                dispatch(openHome());
            }
        } catch (error) {
            console.log(error);
            if (error instanceof Error) {
                dispatch(encounteredError(error.message));
            } else if (typeof error === "string") {
                dispatch(encounteredError(error));
            }
        }
    }
}
