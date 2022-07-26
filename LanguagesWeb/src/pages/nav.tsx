import { useAppSelector } from "../redux/store.ts";
import React from "react";
import HomePage from "./home";

export default function Nav() {
    const currentPage = useAppSelector(state => state.nav.navStack[state.nav.navStack.length - 1]);

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
            return <div>Log in</div>;
    }
}