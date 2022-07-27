import { useAppSelector } from "../redux/store";
import React from "react";
import HomePage from "./home";
import LogInPage from "./logIn";

export default function Nav() {
    const currentPage = useAppSelector(state => state.nav.navStack[state.nav.navStack.length - 1]);

    if (currentPage === undefined) {
        return <LogInPage />;
    }

    switch (currentPage.id) {
        case "home":
            return <HomePage />;

        case "class":
            return <div>Class</div>; 

        case "deck":
            return <div>Deck</div>;     

        case "task":
            return <div>Task</div>;

        default:
            return <LogInPage />;
    }
}