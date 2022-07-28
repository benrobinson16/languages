import { Flex, Heading, Spacer, Stack, VStack } from "@chakra-ui/react";
import React from "react";
import { HomeButton, SignOutButton } from "./buttons";

export default function Layout(props: { children: React.ReactNode }) {
    return (
        <VStack>
            <Flex
                width="100vw"
                padding={4}
                borderBottomColor="gray.200"
                borderBottomWidth={2}
                alignItems="center"
            >
                <HomeButton />
                <Spacer />
                <Heading size="md">Languages</Heading>
                <Spacer />
                <SignOutButton />
            </Flex>
            {props.children}
        </VStack>
    );
}