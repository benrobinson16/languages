import React from "react";
import { Box, Center } from "@chakra-ui/react";

export default function CenteredCard(props: { children: React.ReactNode }) {
    return (
        <Box background="gray.200" height="100vh">
            <Center height="100vh">
                <Box 
                    background="white" 
                    rounded="2xl"
                    width={["100%", "80%", "60%", "40%"]}
                    padding="lg"
                >
                    {props.children}
                </Box>
            </Center>
        </Box>
    );
}