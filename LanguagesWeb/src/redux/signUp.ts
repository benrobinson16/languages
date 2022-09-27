import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import authService from "../services/authService";
import store, { TypedThunk } from "./store";
import { gotUserInfo } from "./auth";
import { openHome } from "./nav";
import { errorToast } from "../helper/toast";
import { registerTeacher } from "../api/endpoints";

interface SignUpState {
    title: string,
    surname: string,
    isLoading: boolean
}

const initialState: SignUpState = {
    title: "",
    surname: "",
    isLoading: false
};

export const signUpSlice = createSlice({
    name: "signup",
    initialState,
    reducers: {
        changeSurname: (state, action: PayloadAction<string>) => {
            if (state.isLoading) return;
            state.surname = action.payload;
        },
        changeTitle: (state, action: PayloadAction<string>) => {
            if (state.isLoading) return;
            state.title = action.payload;
        },
        startedCreatingAccount: (state) => {
            state.isLoading = true;
        },
        failedCreatingAccount: (state) => {
            state.isLoading = false;
        }
    }
});

export const { changeSurname, changeTitle, startedCreatingAccount, failedCreatingAccount } = signUpSlice.actions;

/** Creates an account for a new teacher, using the provided title and surname. */
export const createAccount = (): TypedThunk => {
    return async (dispatch, getState): Promise<void> => {

        // Start the loading animation.
        store.dispatch(startedCreatingAccount());

        const state = getState();
        const title = state.signUp.title;
        const surname = state.signUp.surname;

        // Perform title validation.
        if (title == null || title === "") {
            errorToast("Please enter a title.");
            dispatch(failedCreatingAccount());
            return;
        }

        // Perform surname validation.
        if (surname == null || surname.trim() === "") {
            errorToast("Please enter a surname.");
            dispatch(failedCreatingAccount());
            return;
        }

        try {

            // Authenticate.
            const token = getState().auth.token || await authService.getToken();
            if (!token) throw new Error("Authentication has failed.");

            // Create the account and store user details.
            const user = await registerTeacher.makeRequest(token, { title, surname });
            dispatch(gotUserInfo(user));

            // Open the home screen now that we have all account user information.
            dispatch(openHome());

        } catch (error) {
            errorToast(error);
            dispatch(failedCreatingAccount());
        }
    }
}