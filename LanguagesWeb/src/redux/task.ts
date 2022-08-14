import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import authService from "../services/authService";
import { TypedThunk } from "./store";
import { errorToast, successToast, toast } from "../helper/toast";
import * as endpoints from "../api/endpoints";
import { StudentProgress, Task, TaskSummary } from "../api/models";

interface TaskState {
    isLoading: boolean,
    task: Task | null,
    students: StudentProgress[] | null
}

const initialState: TaskState = {
    isLoading: false,
    task: null,
    students: null
}

export const taskSlice = createSlice({
    name: "task",
    initialState,
    reducers: {
        startedLoading: (state) => {
            state.isLoading = true;
            state.task = null;
            state.students = null;
        },
        finishedLoading: (state, action: PayloadAction<TaskSummary>) => {
            state.task = action.payload.taskDetails;
            state.students = action.payload.students;
            state.isLoading = false;
        }
    }
});

export const { startedLoading, finishedLoading } = taskSlice.actions;

export const loadTaskDetails = (taskId: number): TypedThunk => {
    return async (dispatch, getState) => {
        dispatch(startedLoading());

        try {
            const token = getState().auth.token || await authService.getToken();
            const response = await endpoints.getTask.makeRequest(token, { taskId })
            dispatch(finishedLoading(response))
        } catch (error) {
            errorToast(error);
        }
    };
};

export const sendReminderNotification = (taskId: number, studentId: number): TypedThunk => {
    return async (dispatch, getState) => {
        try {
            const token = getState().auth.token || await authService.getToken();
            await endpoints.reminderNotification.makeRequest(token, { studentId, taskId });
            successToast("Sent.");
        } catch (error) {
            errorToast(error);
        }
    }
}

export const sendCongratsNotification = (taskId: number, studentId: number): TypedThunk => {
    return async (dispatch, getState) => {
        try {
            const token = getState().auth.token || await authService.getToken();
            await endpoints.congratsNotification.makeRequest(token, { studentId, taskId });
            successToast("Sent.");
        } catch (error) {
            errorToast(error);
        }
    }
}