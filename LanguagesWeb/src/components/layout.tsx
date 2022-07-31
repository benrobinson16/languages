import { Flex, Grid, GridItem, Heading, Spacer, Stack, VStack } from "@chakra-ui/react";
import React from "react";
import { useAppSelector } from "../redux/store";
import { BackButton, HomeButton, SignOutButton } from "./buttons";

export default function Layout(props: { children: React.ReactNode }) {
    const page = useAppSelector(state => state.nav.navStack[state.nav.navStack.length - 1]);

    return (
        <VStack>
            <Grid 
                templateColumns="repeat(3, 1fr)" 
                width="100%"
                paddingY={4}
                paddingX={4}
                alignItems="center"
                borderBottomColor="gray.200"
                borderBottomWidth={2}
            >
                <GridItem justifySelf="start">
                    {
                        page != null && page.id == "home" ? <HomeButton /> : <BackButton />
                    }
                </GridItem>
                <GridItem justifySelf="center">
                    <Heading size="md">Languages</Heading>
                </GridItem>
                <GridItem justifySelf="end">
                    <SignOutButton />
                </GridItem>
            </Grid>
            {props.children}
        </VStack>
    );
}