import { Flex, Heading, Spacer, Stack, VStack } from "@chakra-ui/react";
import React from "react";
import ClassList from "../components/classList";
import { SignOutButton } from "../components/buttons";

export default function HomePage() {
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