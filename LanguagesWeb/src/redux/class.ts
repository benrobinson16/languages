import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import authService from "../services/authService";
import { TypedThunk } from "./store";
import { errorToast, successToast } from "../helper/toast";
import * as endpoints from "../api/endpoints";
import { Class, ClassSummary, Task } from "../api/models";
import * as navActions from "./nav";

interface ClassState {
    isLoading: boolean,
    class: Class | null,
    tasks: Task[] | null,
    students: string[] | null,
    showJoinCode: boolean,
}

const initialState: ClassState = {
    isLoading: false,
    class: null,
    tasks: null,
    students: null,
    showJoinCode: false
}

export const classSlice = createSlice({
    name: "class",
    initialState,
    reducers: {
        startedLoading: (state) => {
            state.isLoading = true;
            state.class = null;
            state.tasks = null;
            state.students = null;
            state.showJoinCode = false;
        },
        finishedLoading: (state, action: PayloadAction<ClassSummary>) => {
            state.class = action.payload.classDetails;
            state.tasks = action.payload.tasks;
            state.students = action.payload.students;
            state.isLoading = false;
        },
        showJoinCode: (state) => {
            state.showJoinCode = true;
        },
        closeJoinCode: (state) => {
            state.showJoinCode = false;
        }
    }
});

export const { startedLoading, finishedLoading, showJoinCode, closeJoinCode } = classSlice.actions;

export const loadClassDetails = (classId: number): TypedThunk => {
    return async (dispatch, getState) => {
        const isLoading = getState().class.isLoading;
        if (isLoading) return;
        dispatch(startedLoading());

        try {
            const token = getState().auth.token || await authService.getToken();
            const response = await endpoints.getClass.makeRequest(token, { classId });
            console.log(response);
            dispatch(finishedLoading(response));
        } catch (error) {
            errorToast(error);
        }
    };
};

export const deleteClass = (classId: number): TypedThunk => {
    return async (dispatch, getState) => {
        const deleteText = "Are you sure you would like to delete this class?";
        const confirmed = window.confirm(deleteText);

        if (confirmed) {
            try {
                const token = getState().auth.token || await authService.getToken();
                await endpoints.deleteClass.makeRequestVoid(token, { classId });
                dispatch(navActions.back());
                successToast("Class deleted.");
            } catch (error) {
                errorToast(error);
            }
        }
    }
}