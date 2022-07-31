import { useAppSelector } from "../redux/store";
import React from "react";
import HomePage from "./home";
import LogInPage from "./logIn";
import { createStandaloneToast, ScaleFade } from "@chakra-ui/react";
import Layout from "../components/layout";
import ClassPage from "./class";
import DeckPage from "./deck";
import TaskPage from "./task";

export default function Nav() {
    const currentPage = useAppSelector(state => state.nav.navStack[state.nav.navStack.length - 1]);

    if (currentPage === undefined) {
        return <LogInPage />;
    }

    return (
        <Layout>
            <ScaleFade in={currentPage.id === "home"}>
                <HomePage />
            </ScaleFade>
            <ScaleFade in={currentPage.id === "class"}>
                <ClassPage id={currentPage.data as number} />
            </ScaleFade>
            <ScaleFade in={currentPage.id === "deck"}>
                <DeckPage id={currentPage.data as number} />
            </ScaleFade>
            <ScaleFade in={currentPage.id === "task"}>
                <TaskPage id={currentPage.data as number} />
            </ScaleFade>
        </Layout>
    )

    switch (currentPage.id) {
        case "home":
            return <Layout><HomePage /></Layout>;

        case "class":
            return <Layout><ClassPage id={currentPage.data as number} /></Layout>; 

        case "deck":
            return <Layout><DeckPage id={currentPage.data as number} /></Layout>;     

        case "task":
            return <Layout><TaskPage id={currentPage.data as number} /></Layout>;

        default:
            return <LogInPage />;
    }
}