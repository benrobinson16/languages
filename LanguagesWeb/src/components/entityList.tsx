import React, { useEffect } from "react";
import { loadSummary } from "../redux/summary";
import { useAppDispatch, useAppSelector } from "../redux/store";
import { ClassCard, DeckCard, NewEntityCard, TaskCard } from "./dataCards";
import { Heading, HStack, Icon, VStack, Text, Spinner, Spacer, Button, Flex, Box, Center, useDisclosure, Modal, ModalContent, ModalOverlay, ModalHeader, ModalCloseButton, ModalBody, ModalFooter } from "@chakra-ui/react";
import Card from "./card";
import { Class, Deck, Task } from "../api/models";


export interface EntityListProps<Entity> {
    entities: Entity[] | null,
    createCard: (entity: Entity) => JSX.Element,
    title: string,
    newTite: string,
    information: string
}

export function EntityList<Entity>(props: EntityListProps<Entity>) {
    const { isOpen, onOpen, onClose } = useDisclosure();

    

    let cards: React.ReactNode[] = []

    if (props.entities == null) {
        cards = [<Spinner />];
    } else if (props.entities.length === 0) {
        cards = [<Card><Text>No {props.title.toLowerCase()} have been created.</Text></Card>];
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
            <NewEntityCard title={props.newTite} />
            {cards}
        </VStack>
    )
}

export function ClassList(props: {classes: Class[] | null}) {
    return EntityList({
        entities: props.classes,
        createCard: (entity: Class) => <ClassCard class={entity} />,
        title: "Classes",
        newTite: "New Class",
        information: "Classes are used to group students together. Give each one a descriptive name to tell them apart. To add students to a class, click on the class and then click \"Show Join Code\" - ask your students to enter the code into the mobile app to join."
    });
}

export function DeckList(props: {decks: Deck[] | null}) {
    return EntityList({
        entities: props.decks,
        createCard: (entity: Deck) => <DeckCard deck={entity} />,
        title: "Decks",
        newTite: "New Deck",
        information: "Decks are sets of vocabulary for students to learn. They are made up of a series of flashcards with the foreign language term and the English translation. Whilst a deck you create belongs only to you, others may use it when creating tasks for students."
    });
}

export function TaskList(props: {tasks: Task[] | null}) {
    return EntityList({
        entities: props.tasks,
        createCard: (entity: Task) => <TaskCard task={entity} />,
        title: "Tasks",
        newTite: "New Task",
        information: "Tasks assign a deck to a class, adding its terms to the vocabulary students will review/learn next. Tasks may use decks created by you or any other teacher. Set a due date to indicate the urgency of the task, and the in-app scheduling will ensure students complete it on time."
    });
}