import { useSelector } from "react-redux";
import { RootState, useAppDispatch } from "../redux/store";
import React from "react";

export default function Nav() {
    const dispatch = useAppDispatch();
    const currentPage = useSelector((state: RootState) => state.nav.navStack[state.nav.navStack.length - 1]);

    switch (currentPage.id) {
        case "home":
            return (<div>Home</div>);

        case "classes":
            return <div>Classes</div>;

        case "class":
            return <div>Class</div>;

        case "decks":
            return <div>Decks</div>;        

        case "deck":
            return <div>Deck</div>;     

        case "tasks":
            return <div>Tasks</div>;     

        case "task":
            return <div>Task</div>;

        default:
            return <div>Log in</div>;
    }
}