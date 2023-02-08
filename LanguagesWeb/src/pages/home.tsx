import { Stack } from "@chakra-ui/react";
import React, { useEffect } from "react";
import { DeckList, ClassList, TaskList } from "../components/entityList";
import { useAppDispatch, useAppSelector } from "../redux/store";
import * as summaryActions from "../redux/summary";

// Represents the main dashboard.
export default function HomePage() {
    const dispatch = useAppDispatch();

    // Get the main data from the store.
    const classes = useAppSelector(state => state.summary.classes);
    const decks = useAppSelector(state => state.summary.decks);
    const tasks = useAppSelector(state => state.summary.tasks);

    // Load the data when displayed.
    useEffect(() => {
        dispatch(summaryActions.loadSummary());
    }, [dispatch]);

    return (
        <Stack 
            direction="row" 
            spacing={8} 
            padding={8}
            width="100vw" 
        >
            <ClassList classes={classes} />
            <DeckList decks={decks} />
            <TaskList tasks={tasks} />
        </Stack>
    );
}