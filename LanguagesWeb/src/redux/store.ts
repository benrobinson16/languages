import { configureStore } from "@reduxjs/toolkit";
import { TypedUseSelectorHook, useDispatch, useSelector } from "react-redux";
import { navSlice } from "./nav";
import thunk from "redux-thunk";
import { authSlice } from "./auth";
import { classesSlice } from "./classes";

const store = configureStore({
    reducer: {
        nav: navSlice.reducer,
        auth: authSlice.reducer,
        classes: classesSlice.reducer
    },
    middleware: [thunk]
});

// Export the store and infer its types for typescript checking.
export default store;
export type RootState = ReturnType<typeof store.getState>
export type AppDispatch = typeof store.dispatch

// Typed versions of useDispatch and useSelector to facilitate typescript checking.
export const useAppDispatch: () => AppDispatch = useDispatch
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector