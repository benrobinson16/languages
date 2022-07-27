import React, { useEffect } from "react";
import { Class, Teacher } from "../api/models";
import ClassCard from "../components/classCard";
import { loadClasses } from "../redux/classes";
import { useAppDispatch, useAppSelector } from "../redux/store";

export default function HomePage() {
    const dispatch = useAppDispatch();

    const classes: Class[] | null = useAppSelector(state => state.classes.classes);
    const isLoading: boolean = useAppSelector(state => state.classes.isLoading);
    const errorMessage: string | null = useAppSelector(state => state.classes.errorMessage);
    const user: Teacher = useAppSelector(state => state.auth.user)!;

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
            <div>Hello {user.title} {user.surname}</div>
            {classCards}
        </div>
    );
}