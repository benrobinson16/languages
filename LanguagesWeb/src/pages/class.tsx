import { Heading, SimpleGrid, Spinner, VStack, Text, Flex, Spacer, Button } from "@chakra-ui/react";
import React, { useEffect } from "react";
import { useAppDispatch, useAppSelector } from "../redux/store";
import * as classActions from "../redux/class";
import { TaskList } from "../components/entityList";
import Card from "../components/card";

export default function ClassPage(props: { id: number }) {
    const dispatch = useAppDispatch();

    const isLoading = useAppSelector(state => state.class.isLoading);
    const cla = useAppSelector(state => state.class.class);
    const tasks = useAppSelector(state => state.class.tasks);
    const students = useAppSelector(state => state.class.students);

    useEffect(() => {
        dispatch(classActions.loadClassDetails(props.id));
    }, [dispatch, props.id]);

    if (isLoading) {
        return <Spinner />;
    }

    if (students == null || cla == null || tasks == null) {
        return <Text>This class doesn't seem to exist...</Text>;
    }

    let studentCards = students.map(stu => <Card><Text>{stu}</Text></Card>);
    if (studentCards.length === 0) {
        studentCards = [<Card key="emptycard"><Text>No students have joined the class.</Text></Card>];
    }

    return (
        <VStack width="100vw" padding={8} spacing={8}>
            <Heading alignSelf="start">{cla?.name}</Heading>
            <SimpleGrid width="100%" columns={2} gap={8}>
                <TaskList tasks={tasks} classId={cla.id} />
                <VStack spacing={4}>
                    <Flex width="100%">
                        <Heading>Students</Heading>
                        <Spacer />
                        <Button onClick={() => dispatch(classActions.showJoinCode())}>Show join code</Button>
                    </Flex>
                    {studentCards}
                </VStack>
            </SimpleGrid>
        </VStack>
    ); 
}