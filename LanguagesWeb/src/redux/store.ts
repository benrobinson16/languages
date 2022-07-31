import { AnyAction, configureStore } from "@reduxjs/toolkit";
import { TypedUseSelectorHook, useDispatch, useSelector } from "react-redux";
import { navSlice } from "./nav";
import { ThunkAction, ThunkDispatch } from "redux-thunk";
import { authSlice } from "./auth";
import { summarySlice } from "./summary";
import { signUpSlice } from "./signUp";
import { newClassSlice } from "./newClass";

const store = configureStore({
    reducer: {
        nav: navSlice.reducer,
        auth: authSlice.reducer,
        summary: summarySlice.reducer,
        signUp: signUpSlice.reducer,
        newClass: newClassSlice.reducer,
    }
});

// Export the store and infer its types for typescript checking.
export default store;
export type AppState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
export type TypedDispatch = ThunkDispatch<AppState, any, AnyAction>;
export type TypedThunk<ReturnType = void> = ThunkAction<ReturnType, AppState, unknown, AnyAction>;

// Typed versions of useDispatch and useSelector to facilitate typescript checking.
export const useAppDispatch: () => AppDispatch = useDispatch<TypedDispatch>;
export const useAppSelector: TypedUseSelectorHook<AppState> = useSelector;