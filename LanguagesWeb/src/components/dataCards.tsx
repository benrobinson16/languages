import React from "react";
import {Class, Deck, Task, StudentProgress} from "../api/models";
import Card from "./card";
import {Button, Flex, HStack, Icon, Spacer, Text, VStack} from "@chakra-ui/react";
import { HiOutlinePlusCircle } from "react-icons/hi";
import { AppDispatch, TypedThunk, useAppDispatch } from "../redux/store";
import { openClass, openDeck, openTask } from "../redux/nav";
import { sendCongratsNotification, sendReminderNotification } from "../redux/task";

export function ClassCard(props: {class: Class, key: number}) {
    const dispatch = useAppDispatch();

    return (
        <Card onClick={() => dispatch(openClass(props.class.id))}>
            <Text fontSize="lg" fontWeight="semibold" >{props.class.name}</Text>
            <Text fontSize="md">{props.class.numActiveTasks} active tasks</Text>
            <Text fontSize="md">{props.class.numStudents} students</Text>
        </Card>
    );
}

export function DeckCard(props: {deck: Deck, key: number}) {
    const dispatch = useAppDispatch();

    return (
        <Card onClick={() => dispatch(openDeck(props.deck.deckId))}>
            <Text fontSize="lg" fontWeight="semibold" >{props.deck.name}</Text>
            <Text fontSize="md">{props.deck.numCards ?? 0} cards</Text>
            <Text fontSize="md">Last modified {props.deck.creationDate ?? "Never"}</Text>
        </Card>
    );
}

export function TaskCard(props: {task: Task, key: number}) {
    const dispatch = useAppDispatch();

    return (
        <Card onClick={() => dispatch(openTask(props.task.id))}>
            <Text fontSize="lg" fontWeight="semibold" >{props.task.className}</Text>
            <Text fontSize="md">{props.task.deckName}</Text>
            <Text fontSize="md">Due by {props.task.dueDate}</Text>
        </Card>
    );
}

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
                <Text color="blue.400">{props.title}</Text>
            </HStack>
        </Card>
    )
}

export function ProgressCard(props: { studentProgress: StudentProgress, taskId: number }) {
    const dispatch = useAppDispatch();

    let color: string;
    let buttonText: string;
    let notification: TypedThunk<void>;

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
                    <Text fontWeight="semibold">{props.studentProgress.name}</Text>
                    <Text color={color}>{props.studentProgress.progress} %</Text>
                </VStack>
                <Spacer />
                <Button onClick={() => dispatch(notification)}>{buttonText}</Button>
            </Flex>
        </Card>
    );
}