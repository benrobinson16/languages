import React, { useEffect } from "react";
import { Class } from "../api/models";
import ClassCard from "../components/classCard";
import { loadClasses } from "../redux/classes";
import { useAppDispatch, useAppSelector } from "../redux/store";

export default function HomePage() {
    const dispatch = useAppDispatch();

    let classes: Class[] | null = useAppSelector(state => state.classes.classes);
    let isLoading: boolean = useAppSelector(state => state.classes.isLoading);
    let errorMessage: string | null = useAppSelector(state => state.classes.errorMessage);
    
    useEffect(() => {
        dispatch(loadClasses());
    }, [dispatch]);

    if (errorMessage) { 
        return <div>{errorMessage}</div>;
    }

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
            <div>Hello</div>
            {classCards}
        </div>
    );
}