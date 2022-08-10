import { VStack, Heading, SimpleGrid, Spinner } from "@chakra-ui/react";
import React, { useEffect } from "react";
import { ProgressList } from "../components/entityList";
import MotionBox from "../components/motionBox";
import * as nav from "../redux/nav";
import { useAppDispatch, useAppSelector } from "../redux/store";
import { loadTaskDetails } from "../redux/task";

export default function TaskPage(props: { id: number }) {
    const dispatch = useAppDispatch();

    const isLoading = useAppSelector(state => state.task.isLoading);
    const task = useAppSelector(state => state.task.task);
    const students = useAppSelector(state => state.task.students);

    useEffect(() => {
        console.log("loading task");
        console.log(props.id);
        dispatch(loadTaskDetails(props.id));
    }, [dispatch, props.id]);

    if (isLoading || task == null || students == null) {
        return <Spinner />;
    }

    return (
        <VStack width="100vw" padding={8} spacing={8}>
            <SimpleGrid width="100%" columns={3} gap={8} alignItems="center">
                <MotionBox maxWidth={false} justifySelf="start">
                    <Heading as="button" onClick={() => dispatch(nav.openDeck(task.deckId))} textAlign="left">{task.deckName}</Heading>
                </MotionBox>
                <Heading size="md" justifySelf="center" color="gray.500">assigned to</Heading>
                <MotionBox maxWidth={false} justifySelf="end">
                    <Heading as="button" onClick={() => dispatch(nav.openClass(task.classId))} textAlign="right">{task.className}</Heading>
                </MotionBox>
            </SimpleGrid>
            <SimpleGrid width="100%" columns={2} gap={8}>
                <ProgressList students={students} taskId={task.id} />
            </SimpleGrid>
        </VStack>
    );
}

