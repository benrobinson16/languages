import React from "react";
import {Class, Deck, Task} from "../api/models";
import Card from "./card";
import {HStack, Icon, Text} from "@chakra-ui/react";
import { HiOutlinePlusCircle } from "react-icons/hi";
import { useAppDispatch } from "../redux/store";
import { openClass, openDeck, openTask } from "../redux/nav";
import { AnyAction } from "@reduxjs/toolkit";

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
        <Card onClick={() => dispatch(openDeck(props.deck.id))}>
            <Text fontSize="lg" fontWeight="semibold" >{props.deck.name}</Text>
            <Text fontSize="md">{props.deck.cards.length} cards</Text>
            <Text fontSize="md">Last modified {props.deck.dateModified.toDateString()}</Text>
        </Card>
    );
}

export function TaskCard(props: {task: Task, key: number}) {
    const dispatch = useAppDispatch();

    return (
        <Card onClick={() => dispatch(openTask(props.task.id))}>
            <Text fontSize="lg" fontWeight="semibold" >{props.task.className}</Text>
            <Text fontSize="md">{props.task.deckName}</Text>
            <Text fontSize="md">Due by {props.task.dueDate.toDateString()}</Text>
            <Text fontSize="md">{props.task.studentsComplete} students complete</Text>
        </Card>
    );
}

export function NewEntityCard(props: {title: string, action: AnyAction}) {
    const dispatch = useAppDispatch();

    return (
        <Card
            background="blue.50"
            border="blue.200"
            onClick={() => dispatch(props.action)}
        >
            <HStack>
                <Icon as={HiOutlinePlusCircle} color="blue.400"/>
                <Text color="blue.400">{props.title}</Text>
            </HStack>
        </Card>
    )
}