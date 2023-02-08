import { useAppSelector } from "../redux/store";
import React from "react";
import HomePage from "./home";
import LogInPage from "./logIn";
import { ScaleFade } from "@chakra-ui/react";
import Layout from "../components/layout";
import ClassPage from "./class";
import DeckPage from "./deck";
import TaskPage from "./task";
import JoinCodeModal from "../modals/joinCode";
import NewClassModal from "../modals/newClass";
import NewTaskModal from "../modals/newTask";
import NewDeckModal from "../modals/newDeck";

// Manages the current navigation state and the current page.
export default function Nav() {
    const currentPage = useAppSelector(state => state.nav.navStack[state.nav.navStack.length - 1]);

    // If the user is not logged in, show the log in page.
    if (currentPage === undefined) {
        return <LogInPage />;
    }

    return (
        <Layout>
            <ScaleFade in={currentPage.id === "home"}>
                {currentPage.id === "home" ? <HomePage /> : <></>}
            </ScaleFade>
            <ScaleFade in={currentPage.id === "class"}>
                {currentPage.id === "class" ? <ClassPage id={currentPage.data as number} /> : <></>}
            </ScaleFade>
            <ScaleFade in={currentPage.id === "deck"}>
                {currentPage.id === "deck" ? <DeckPage id={currentPage.data as number} /> : <></>}
            </ScaleFade>
            <ScaleFade in={currentPage.id === "task"}>
                {currentPage.id === "task" ? <TaskPage id={currentPage.data as number} /> : <></>}
            </ScaleFade>

            {/* MODALS */}
            <JoinCodeModal />
            <NewClassModal />
            <NewTaskModal />
            <NewDeckModal />
        </Layout>
    );
}