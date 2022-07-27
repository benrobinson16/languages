import { VStack, Heading, Text } from "@chakra-ui/react";
import React, { useEffect } from "react";
import CenteredCard from "../components/centeredCard";
import { SignInWithMicrosoftButton } from "../components/buttons";
import { getToken, saveTokenAndRedirect } from "../redux/auth";
import { openHome, openSignUp } from "../redux/nav";
import { useAppDispatch, useAppSelector } from "../redux/store";
import authService from "../services/authService";

export default function LogInPage() {
    const dispatch = useAppDispatch();
    const token = useAppSelector(state => state.auth.token);
    const user = useAppSelector(state => state.auth.user);

    useEffect(() => {
        authService.registerLoginCallback(token => {
            dispatch(saveTokenAndRedirect(token));
        });

        if (authService.instance.getAllAccounts().length > 0) {
            dispatch(getToken(true));
        }
    });

    if (token != null && user != null) {
        // Signed in and account already exists.
        dispatch(openHome());
    } else if (token != null) {
        // Signed in but account does not exist.
        dispatch(openSignUp());
    }

    return (
        <CenteredCard>
            <VStack
                padding={8}
                spacing={8}
                align="center"
                textAlign="center"
            >
                <Heading>Languages</Heading>
                <Text>A teacher platform to assign vocabularly learning homework to classes. Please sign in to continue.</Text>
                <SignInWithMicrosoftButton />
            </VStack>
        </CenteredCard>
    );
}