import React from "react";
import { useAppDispatch } from "../redux/store";
import { ClassCard, DeckCard, NewEntityCard, TaskCard } from "./dataCards";
import { Heading, VStack, Text, Spinner, Spacer, Flex, Center, useDisclosure, Modal, ModalContent, ModalOverlay, ModalHeader, ModalCloseButton, ModalBody } from "@chakra-ui/react";
import Card from "./card";
import { Class, Deck, Task } from "../api/models";
import { openClass, openDeck, openTask } from "../redux/nav";
import * as newClassActions from "../redux/newClass";
import * as newTaskActions from "../redux/newTask";
import * as newDeckActions from "../redux/newDeck";
import { AnyAction } from "@reduxjs/toolkit";

export interface EntityListProps<Entity> {
    entities: Entity[] | null,
    createCard: (entity: Entity) => JSX.Element,
    title: string,
    newTite: string,
    information: string,
    onSelect: (entity: Entity) => void,
    newEntityAction: AnyAction
}

export function EntityList<Entity>(props: EntityListProps<Entity>) {
    const { isOpen, onOpen, onClose } = useDisclosure();

    let cards: React.ReactNode[] = []

    if (props.entities == null) {
        cards = [<Spinner key="spinner" />];
    } else if (props.entities.length === 0) {
        cards = [<Card key="emptycard"><Text>No {props.title.toLowerCase()} have been created.</Text></Card>];
    } else {
        for (let i in props.entities) {
            cards.push(props.createCard(props.entities[i]));
        }
    }

    return (
        <VStack
            spacing={4}
            width="100%"
            align="start"
        >
            <Flex
                width="100%"
                align="center"
                verticalAlign="center"
            >
                <Heading>{props.title}</Heading>
                <Spacer />
                <Center 
                    as="a" 
                    onClick={onOpen}
                    bgColor="gray.200" 
                    rounded="full" 
                    w={6} 
                    h={6}
                >
                    ?
                </Center>

                <Modal isOpen={isOpen} onClose={onClose} isCentered>
                    <ModalOverlay />
                    <ModalContent>
                        <ModalHeader>{props.title}</ModalHeader>
                        <ModalCloseButton />
                        <ModalBody marginBottom={2}>
                            <Text>{props.information}</Text>
                        </ModalBody>
                    </ModalContent>
                </Modal>
            </Flex>
            <NewEntityCard title={props.newTite} action={props.newEntityAction} />
            {cards}
        </VStack>
    );
}

export function ClassList(props: {classes: Class[] | null}) {
    const dispatch = useAppDispatch();

    return EntityList({
        entities: props.classes,
        createCard: (entity: Class) => <ClassCard class={entity} key={entity.id} />,
        title: "Classes",
        newTite: "New Class",
        information: "Classes are used to group students together. Give each one a descriptive name to tell them apart. To add students to a class, click on the class and then click \"Show Join Code\" - ask your students to enter the code into the mobile app to join.",
        onSelect: (entity: Class) => dispatch(openClass(entity.id)),
        newEntityAction: newClassActions.showNewClassModal()
    });
}

export function DeckList(props: {decks: Deck[] | null}) {
    const dispatch = useAppDispatch();

    return EntityList({
        entities: props.decks,
        createCard: (entity: Deck) => <DeckCard deck={entity} key={entity.deckId} />,
        title: "Decks",
        newTite: "New Deck",
        information: "Decks are sets of vocabulary for students to learn. They are made up of a series of flashcards with the foreign language term and the English translation. Whilst a deck you create belongs only to you, others may use it when creating tasks for students.",
        onSelect: (entity: Deck) => dispatch(openDeck(entity.deckId)),
        newEntityAction: newDeckActions.showModal()
    });
}

export function TaskList(props: {tasks: Task[] | null, classId?: number}) {
    const dispatch = useAppDispatch();

    return EntityList({
        entities: props.tasks,
        createCard: (entity: Task) => <TaskCard task={entity} key={entity.taskId} />,
        title: "Tasks",
        newTite: "New Task",
        information: "Tasks assign a deck to a class, adding its terms to the vocabulary students will review/learn next. Tasks may use decks created by you or any other teacher. Set a due date to indicate the urgency of the task, and the in-app scheduling will ensure students complete it on time.",
        onSelect: (entity: Task) => dispatch(openTask(entity.taskId)),
        newEntityAction: props.classId == null ? newTaskActions.showModal() : newTaskActions.showModalForClass(props.classId)
    });
}