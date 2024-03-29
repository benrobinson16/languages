import { SimpleGrid, Spinner, VStack, Text, Flex, Spacer, Button } from "@chakra-ui/react";
import React, { useEffect } from "react";
import { useAppDispatch, useAppSelector } from "../redux/store";
import * as classActions from "../redux/class";
import { StudentList, TaskList } from "../components/entityList";
import Card from "../components/card";
import EditableHeading from "../components/editableHeading";

// Represents the main class page for a given class.
export default function ClassPage(props: { id: number }) {
    const dispatch = useAppDispatch();

    // Get data from the store.
    const isLoading = useAppSelector(state => state.class.isLoading);
    const cla = useAppSelector(state => state.class.class);
    const tasks = useAppSelector(state => state.class.tasks);
    const students = useAppSelector(state => state.class.students);

    // Get the class details on appear.
    useEffect(() => {
        dispatch(classActions.loadClassDetails(props.id));
    }, [dispatch, props.id]);

    // Only show a spinner if the class is loading.
    if (isLoading) {
        return <Spinner />;
    }

    // Unexpected situation. Abort.
    if (students == null || cla == null || tasks == null) {
        return <Text>This class doesn't seem to exist...</Text>;
    }

    // Generate list of students.
    let studentCards = students.map(stu => <Card><Text>{stu}</Text></Card>);
    if (studentCards.length === 0) {
        studentCards = [<Card key="emptycard"><Text textAlign="left">No students have joined the class.</Text></Card>];
    }

    return (
        <VStack width="100vw" padding={8} spacing={8}>
            <Flex width="100%">
                <EditableHeading initialValue={cla?.name} onSave={(value) => dispatch(classActions.editClassName(props.id, value))} />
                <Spacer />
                <Button onClick={() => dispatch(classActions.showJoinCode())}>Show join code</Button>
                <Button onClick={() => dispatch(classActions.deleteClass(props.id))} marginLeft={2}>Delete</Button>
            </Flex>
            <SimpleGrid width="100%" columns={2} gap={8}>
                <TaskList tasks={tasks} classId={cla.id} />
                <StudentList students={students} />
            </SimpleGrid>
        </VStack>
    ); 
}