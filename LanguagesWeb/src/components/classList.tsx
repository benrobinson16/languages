import React, { useEffect } from "react";
import { loadSummary } from "../redux/summary";
import { useAppDispatch, useAppSelector } from "../redux/store";
import ClassCard from "./classCard";

export default function ClassList() {
    const dispatch = useAppDispatch();

    const classes = useAppSelector(state => state.summary.classes);
    const isLoading = useAppSelector(state => state.summary.isLoading);

    if (isLoading) {
        return <div>Loading...</div>;
    }

    if (classes != null && classes.length === 0) {
        return <div>No classes have been created.</div>;
    }

    let classCards: React.ReactNode[] = []
    if (classes != null) {
        for (let i in classes) {
            classCards.push(<ClassCard class={classes[i]} />);
        }
    }

    return (
        <div>
            {classCards};
        </div>
    )
}