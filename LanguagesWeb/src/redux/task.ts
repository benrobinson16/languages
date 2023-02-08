import { createSlice, PayloadAction } from "@reduxjs/toolkit";
import authService from "../services/authService";
import { TypedThunk } from "./store";
import { errorToast, successToast } from "../helper/toast";
import * as endpoints from "../api/endpoints";
import { StudentProgress, Task, TaskSummary } from "../api/models";
import * as navActions from "./nav";

interface TaskState {
    isLoading: boolean,
    task: Task | null,
    students: StudentProgress[] | null,
    dueDate: number | null,
    isSaving: boolean
}

const initialState: TaskState = {
    isLoading: false,
    task: null,
    students: null,
    dueDate: null,
    isSaving: false
}

export const taskSlice = createSlice({
    name: "task",
    initialState,
    reducers: {
        // Log that the system is currently loading task details.
        startedLoading: (state) => {
            state.isLoading = true;
            state.task = null;
            state.students = null;
        },
        // Log that the system has finished loading task details.
        // Save the task details from the server's response.
        finishedLoading: (state, action: PayloadAction<TaskSummary>) => {
            state.task = action.payload.taskDetails;
            state.students = action.payload.students;
            state.isLoading = false;
        },
        // Save the new due date.
        editedDueDate: (state, action: PayloadAction<number>) => {
            state.dueDate = action.payload;
        },
        // Log that the system is currently saving the task.
        startedSaving: (state) => {
            state.isSaving = true
        },
        // Log that the system has finished saving the task.
        finishedSaving: (state, action: PayloadAction<TaskSummary>) => {
            state.task = action.payload.taskDetails;
            state.students = action.payload.students;
            state.isLoading = false;
            state.isSaving = false;
        },
        // Log that the system has failed to save the task.
        failedSaving: (state) => {
            state.isSaving = false;
        }
    }
});

export const { startedLoading, finishedLoading, editedDueDate, startedSaving, finishedSaving, failedSaving } = taskSlice.actions;

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

export const saveTaskDueDate = (): TypedThunk => {
    return async (dispatch, getState) => {
        dispatch(startedSaving());
        
        const task = getState().task.task;
        const newDueDate = getState().task.dueDate;
        if (task === null || newDueDate === null) return;

        if (newDueDate < Date.now()) {
            errorToast("Due date must be in the future.");
            dispatch(failedSaving());
            dispatch(loadTaskDetails(task.id));
            return;
        }

        try {
            const token = getState().auth.token || await authService.getToken();
            await endpoints.editTask.makeRequest(token, { taskId: task.id, deckId: task.deckId, classId: task.classId, dueDate: newDueDate });
            const response = await endpoints.getTask.makeRequest(token, { taskId: task.id });
            dispatch(finishedSaving(response));
            successToast("Saved new due date.");
        } catch (error) {
            errorToast(error);
            dispatch(failedSaving());
        }
    };
};

export const sendReminderNotification = (taskId: number, studentId: number): TypedThunk => {
    return async (dispatch, getState) => {
        try {
            const token = getState().auth.token || await authService.getToken();
            await endpoints.reminderNotification.makeRequestVoid(token, { studentId, taskId });
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
            await endpoints.congratsNotification.makeRequestVoid(token, { studentId, taskId });
            successToast("Sent.");
        } catch (error) {
            errorToast(error);
        }
    }
}

export const deleteTask = (taskId: number): TypedThunk => {
    return async (dispatch, getState) => {
        const deleteText = "Are you sure you would like to delete this task?";
        const confirmed = window.confirm(deleteText);

        if (confirmed) {
            try {
                const token = getState().auth.token || await authService.getToken();
                await endpoints.deleteTask.makeRequestVoid(token, { taskId });
                dispatch(navActions.back());
            } catch (error) {
                errorToast(error);
            }
        }
    }
}