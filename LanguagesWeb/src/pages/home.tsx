import { Flex, Heading, Input, Modal, ModalBody, ModalCloseButton, ModalContent, ModalFooter, ModalHeader, ModalOverlay, Spacer, Stack, VStack } from "@chakra-ui/react";
import React, { useEffect } from "react";
import { DeckList, ClassList, TaskList } from "../components/entityList";
import { AppButton, SignOutButton } from "../components/buttons";
import { useAppDispatch, useAppSelector } from "../redux/store";
import { loadSummary } from "../redux/summary";
import Layout from "../components/layout";
import { ClassCard } from "../components/dataCards";
import { Class } from "../api/models";
import * as newClass from "../redux/newClass";
import NewClassModal from "../modals/newClass";

export default function HomePage() {
    const dispatch = useAppDispatch();

    const classes = useAppSelector(state => state.summary.classes);
    const decks = useAppSelector(state => state.summary.decks);
    const tasks = useAppSelector(state => state.summary.tasks);

    useEffect(() => {
        dispatch(loadSummary());
    }, [dispatch]);

    return (
        <>
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
        
            <NewClassModal />
        </>
    );
}