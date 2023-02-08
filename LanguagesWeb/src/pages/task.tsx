import { VStack, Heading, SimpleGrid, Spinner, Flex, Spacer } from "@chakra-ui/react";
import React, { useEffect } from "react";
import { AppButton, DestructiveButton } from "../components/buttons";
import DatePicker from "../components/datePicker";
import { ProgressList } from "../components/entityList";
import MotionBox from "../components/motionBox";
import * as nav from "../redux/nav";
import { useAppDispatch, useAppSelector } from "../redux/store";
import * as taskActions from "../redux/task";

// Shows details for a specific task.
export default function TaskPage(props: { id: number }) {
    const dispatch = useAppDispatch();

    // Get data from the store.
    const isLoading = useAppSelector(state => state.task.isLoading);
    const task = useAppSelector(state => state.task.task);
    const students = useAppSelector(state => state.task.students);
    const isSaving = useAppSelector(state => state.task.isSaving);

    // Load the task details on appear.
    useEffect(() => {
        dispatch(taskActions.loadTaskDetails(props.id));
    }, [dispatch, props.id]);

    // Show a spinner if the task is loading.
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
                <VStack
                    spacing={4}
                    width="100%"
                    align="start"
                >
                    <Heading>Due Date:</Heading>
                    <DatePicker date={new Date(task.dueDate)} onChange={d => dispatch(taskActions.editedDueDate(d.valueOf()))} />
                    <Flex width="100%">
                        <AppButton onClick={() => dispatch(taskActions.saveTaskDueDate())} isLoading={isSaving}>Save</AppButton>
                        <Spacer />
                        <DestructiveButton onClick={() => dispatch(taskActions.deleteTask(props.id))}>Delete Task</DestructiveButton>
                    </Flex>
                </VStack>
            </SimpleGrid>
        </VStack>
    );
}
