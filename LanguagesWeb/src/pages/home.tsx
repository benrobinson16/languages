import { Flex, Heading, Spacer, Stack, VStack } from "@chakra-ui/react";
import React, { useEffect } from "react";
import ClassList from "../components/classList";
import { SignOutButton } from "../components/buttons";
import { useAppDispatch } from "../redux/store";
import { loadSummary } from "../redux/summary";

export default function HomePage() {
    const dispatch = useAppDispatch();

    useEffect(() => {
        dispatch(loadSummary());
    }, [dispatch]);

    return (
        <VStack>
            <Flex
                width="100vw"
                padding={4}
                borderBottomColor="gray.200"
                borderBottomWidth={2}
                alignItems="center"
            >
                <Heading size="md">Languages</Heading>
                <Spacer />
                <SignOutButton />
            </Flex>
            <Stack direction="row" spacing={8}>
                <ClassList />
                <ClassList />
                <ClassList />
            </Stack>
        </VStack>
        
    );
}