import { VStack, Heading, Text } from "@chakra-ui/react";
import React, { useEffect } from "react";
import CenteredCard from "../components/centeredCard";
import { SignInWithMicrosoftButton } from "../components/buttons";
import * as authActions from "../redux/auth";
import { useAppDispatch } from "../redux/store";
import authService from "../services/authService";
import SignUpDrawer from "../modals/signUp";

// The splash screen for unauthenticated users.
export default function LogInPage() {
    const dispatch = useAppDispatch();

    // Register a callback to handle if the user has been redirected here
    // from Microsoft Authentication. Try to get a token silently if the
    // user has already signed in previously.
    useEffect(() => {
        authService.registerLoginCallback(token => {
            dispatch(authActions.saveTokenAndRedirect(token));
        });

        if (authService.instance.getAllAccounts().length > 0) {
            dispatch(authActions.getToken(true));
        }
    });

    return (
        <>
            <CenteredCard>
                <VStack
                    padding={8}
                    spacing={8}
                    align="center"
                    textAlign="center"
                >
                    <Heading>Languages</Heading>
                    <Text>A teacher platform to assign vocabularly learning homework to classes. Please sign in to continue.</Text>
                    <Text color="red">The server/database is currently offline. Please start the server before using the app.</Text>
                    <SignInWithMicrosoftButton />
                </VStack>
            </CenteredCard>

            <SignUpDrawer />
        </>
    );
}