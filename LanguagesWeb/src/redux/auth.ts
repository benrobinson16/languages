import { User } from "../api/models";
import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import authService from "../services/authService";
import apiService from "../services/apiService";

interface AuthState {
    token: string | null,
    user: User | null,
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
        gotUserInfo: (state, action: PayloadAction<User>) => {
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

export const getToken = () => { 
    return async (dispatch, getState) => {
        if (getState().auth.isAuthenticating) {
            return;
        }

        dispatch(startedAuthenticating());

        try {
            const token = await authService.getToken();
            dispatch(gotToken(token));
            const userInfo = await apiService.getUserDetails(token);
            dispatch(gotUserInfo(userInfo));
        } catch (error) {
            dispatch(encounteredError(error.message));
        }
    }
}
