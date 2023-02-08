import React from "react";
import { ClassCard, DeckCard, NewEntityCard, ProgressCard, TaskCard } from "./dataCards";
import { Heading, VStack, Text, Spinner, Spacer, Flex, Center, useDisclosure, Modal, ModalContent, ModalOverlay, ModalHeader, ModalCloseButton, ModalBody } from "@chakra-ui/react";
import UICard from "./card";
import { Class, Deck, StudentProgress, Task, Card } from "../api/models";
import * as newClassActions from "../redux/newClass";
import * as newTaskActions from "../redux/newTask";
import * as newDeckActions from "../redux/newDeck";
import VocabCard from "./vocabCard";
import * as deckActions from "../redux/deck";
import { AppDispatch } from "../redux/store";

// The generic props for an entity list.
export interface EntityListProps<Entity> {
    entities: Entity[] | null,
    createCard: (entity: Entity) => JSX.Element,
    title: string,
    newTitle: string | null,
    information: string,
    newEntityAction: (dispatch: AppDispatch) => void,
    newCardAtEnd?: boolean
}

// Represents a list of entities (of any type).
export function EntityList<Entity>(props: EntityListProps<Entity>) {
    const { isOpen, onOpen, onClose } = useDisclosure();

    let cards: React.ReactNode[] = []

    if (props.entities == null) {
        cards = [<Spinner key="spinner" />];
    } else if (props.entities.length === 0) {
        cards = [<UICard key="emptycard"><Text textAlign="left">No {props.title.toLowerCase()} exist.</Text></UICard>];
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
                    as="button" 
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
                            <Text textAlign="left">{props.information}</Text>
                        </ModalBody>
                    </ModalContent>
                </Modal>
            </Flex>
            {
                !props.newCardAtEnd && props.newTitle != null && props.newEntityAction != null ? (
                    <NewEntityCard title={props.newTitle} action={props.newEntityAction} />
                ) : null
            }
            {cards}
            {
                props.newCardAtEnd && props.newTitle != null && props.newEntityAction != null ? (
                    <NewEntityCard title={props.newTitle} action={props.newEntityAction} />
                ) : null
            }
        </VStack>
    );
}

// Represents a list of classes.
export function ClassList(props: {classes: Class[] | null}) {
    return EntityList({
        entities: props.classes,
        createCard: (entity: Class) => <ClassCard class={entity} key={entity.id} />,
        title: "Classes",
        newTitle: "New Class",
        information: "Classes are used to group students together. Give each one a descriptive name to tell them apart. To add students to a class, click on the class and then click \"Show Join Code\" - ask your students to enter the code into the mobile app to join.",
        newEntityAction: (dispatch: AppDispatch) => dispatch(newClassActions.showNewClassModal())
    });
}

// Represents a list of decks.
export function DeckList(props: {decks: Deck[] | null}) {
    return EntityList({
        entities: props.decks,
        createCard: (entity: Deck) => <DeckCard deck={entity} key={entity.deckId} />,
        title: "Decks",
        newTitle: "New Deck",
        information: "Decks are sets of vocabulary for students to learn. They are made up of a series of flashcards with the foreign language term and the English translation. Whilst a deck you create belongs only to you, others may use it when creating tasks for students.",
        newEntityAction: (dispatch: AppDispatch) => dispatch(newDeckActions.showModal())
    });
}

// Represents a list of cards.
export function TaskList(props: {tasks: Task[] | null, classId?: number}) {
    return EntityList({
        entities: props.tasks,
        createCard: (entity: Task) => <TaskCard task={entity} key={entity.id} />,
        title: "Tasks",
        newTitle: "New Task",
        information: "Tasks assign a deck to a class, adding its terms to the vocabulary students will review/learn next. Tasks may use decks created by you or any other teacher. Set a due date to indicate the urgency of the task, and the in-app scheduling will ensure students complete it on time.",
        newEntityAction: (dispatch: AppDispatch) => dispatch(props.classId == null ? newTaskActions.showModal() : newTaskActions.showModalForClass(props.classId))
    });
}

// Represents a list of students and their progress through a task.
export function ProgressList(props: {students: StudentProgress[] | null, taskId: number}) {
    return EntityList({
        entities: props.students,
        createCard: (entity: StudentProgress) => <ProgressCard studentProgress={entity} taskId={props.taskId} key={entity.studentId} />,
        title: "Students",
        newTitle: null,
        information: "View student progress through the task. Percentage is a measure of how many of the cards each student has mastered.",
        newEntityAction: (dispatch: AppDispatch) => { }
    });
}

// Represents a list of students (without progress information).
export function StudentList(props: {students: string[] | null}) {
    return EntityList({
        entities: props.students,
        createCard: (entity: string) => <UICard key={entity}><Text textAlign="left">{entity}</Text></UICard>,
        title: "Students",
        newTitle: null,
        information: "A list of all students in the class. Students can join the class by entering the join code into the mobile app.",
        newEntityAction: (dispatch: AppDispatch) => { }
    });
}

// Represents a list of cards in a deck.
export function CardList(props: {cards: Card[] | null, deck: Deck | null}) {
    return EntityList({
        entities: props.cards,
        createCard: (entity: Card) => <VocabCard card={entity} deck={props.deck!} key={entity.cardId} />,
        title: "Cards",
        newTitle: "New Card",
        information: "A list of cards in the deck. Click a term to edit it.",
        newEntityAction: (dispatch: AppDispatch) => props.deck == null ? null : dispatch(deckActions.newCard(props.deck)),
        newCardAtEnd: true
    });
}