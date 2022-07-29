import React from "react";
import {Class, Deck, Task} from "../api/models";
import Card from "./card";
import {HStack, Icon, Text} from "@chakra-ui/react";
import { HiOutlinePlusCircle } from "react-icons/hi";

export function ClassCard(props: {class: Class}) {
    return (
        <Card>
            <Text fontSize="lg" fontWeight="semibold" >{props.class.name}</Text>
            <Text fontSize="md">{props.class.numActiveTasks} active tasks</Text>
            <Text fontSize="md">{props.class.numStudents} students</Text>
        </Card>
    );
}

export function DeckCard(props: {deck: Deck}) {
    return (
        <Card>
            <Text fontSize="lg" fontWeight="semibold" >{props.deck.name}</Text>
            <Text fontSize="md">{props.deck.cards.length} cards</Text>
            <Text fontSize="md">Last modified {props.deck.dateModified.toDateString()}</Text>
        </Card>
    );
}

export function TaskCard(props: {task: Task}) {
    return (
        <Card>
            <Text fontSize="lg" fontWeight="semibold" >{props.task.className}</Text>
            <Text fontSize="md">{props.task.deckName}</Text>
            <Text fontSize="md">Due by {props.task.dueDate.toDateString()}</Text>
            <Text fontSize="md">{props.task.studentsComplete} students complete</Text>
        </Card>
    );
}

export function NewEntityCard(props: {title: string}) {
    return (
        <Card
            background="blue.50"
            border="blue.200"
        >
            <HStack>
                <Icon as={HiOutlinePlusCircle} size="2rem" color="blue.400"/>
                <Text color="blue.400">{props.title}</Text>
            </HStack>
        </Card>
    )
}