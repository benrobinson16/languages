import React from "react";
import {Class, Deck, Task, StudentProgress} from "../api/models";
import Card from "./card";
import {Button, Flex, HStack, Icon, Spacer, Text, VStack} from "@chakra-ui/react";
import { HiOutlinePlusCircle } from "react-icons/hi";
import { AppDispatch, TypedThunk, useAppDispatch } from "../redux/store";
import { openClass, openDeck, openTask } from "../redux/nav";
import { sendCongratsNotification, sendReminderNotification } from "../redux/task";

// A view representing a single class.
export function ClassCard(props: {class: Class, key: number}) {
    const dispatch = useAppDispatch();

    let studentsText = "students";
    if (props.class.numStudents === 1) {
        studentsText = "student";
    }

    return (
        <Card onClick={() => dispatch(openClass(props.class.id))}>
            <Text textAlign="left" fontSize="lg" fontWeight="semibold" >{props.class.name}</Text>
            <Text textAlign="left" fontSize="md">{props.class.numActiveTasks} active tasks</Text>
            <Text textAlign="left" fontSize="md">{props.class.numStudents} {studentsText}</Text>
        </Card>
    );
}

// A view representing a single deck.
export function DeckCard(props: {deck: Deck, key: number}) {
    const dispatch = useAppDispatch();

    const dateStr = props.deck.creationDate ? new Date(props.deck.creationDate).toDateString() : "Never";

    let cardsText = "cards";
    if (props.deck.numCards === 1) {
        cardsText = "card";
    }

    return (
        <Card onClick={() => dispatch(openDeck(props.deck.deckId))}>
            <Text textAlign="left" fontSize="lg" fontWeight="semibold" >{props.deck.name}</Text>
            <Text textAlign="left" fontSize="md">{props.deck.numCards ?? 0} {cardsText}</Text>
            <Text textAlign="left" fontSize="md">Created {dateStr}</Text>
        </Card>
    );
}

// A view representing a single task.
export function TaskCard(props: {task: Task, key: number}) {
    const dispatch = useAppDispatch();

    const dateStr = props.task.dueDate ? new Date(props.task.dueDate).toDateString() : "Error";

    return (
        <Card onClick={() => dispatch(openTask(props.task.id))}>
            <Text textAlign="left" fontSize="lg" fontWeight="semibold" >{props.task.deckName}</Text>
            <Text textAlign="left" fontSize="md">{props.task.className}</Text>
            <Text textAlign="left" fontSize="md">Due by {dateStr}</Text>
        </Card>
    );
}

// A button for creating new entities.
export function NewEntityCard(props: {title: string, action: (dispatch: AppDispatch) => void}) {
    const dispatch = useAppDispatch();

    return (
        <Card
            background="blue.50"
            border="blue.200"
            onClick={() => props.action(dispatch)}
        >
            <HStack>
                <Icon as={HiOutlinePlusCircle} color="blue.400"/>
                <Text textAlign="left" color="blue.400">{props.title}</Text>
            </HStack>
        </Card>
    )
}

// A card representing student progress through a task.
export function ProgressCard(props: { studentProgress: StudentProgress, taskId: number }) {
    const dispatch = useAppDispatch();

    let color: string;
    let buttonText: string;
    let notification: TypedThunk<void>;

    // Conditionally apply colors and notification type.
    if (props.studentProgress.progress >= 95) {
        color = "green";
        buttonText = "👏";
        notification = sendCongratsNotification(props.taskId, props.studentProgress.studentId);
    } else if (props.studentProgress.progress >= 75) {
        color = "orange";
        buttonText = "🔔";
        notification = sendReminderNotification(props.taskId, props.studentProgress.studentId);
    } else {
        color = "red";
        buttonText = "🔔";
        notification = sendReminderNotification(props.taskId, props.studentProgress.studentId);
    }

    return (
        <Card>
            <Flex alignItems="center" width="100%">
                <VStack alignItems="start">
                    <Text textAlign="left" fontWeight="semibold">{props.studentProgress.name}</Text>
                    <Text textAlign="left" color={color}>{props.studentProgress.progress} %</Text>
                </VStack>
                <Spacer />
                <Button onClick={() => dispatch(notification)}>{buttonText}</Button>
            </Flex>
        </Card>
    );
}