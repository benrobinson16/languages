import { Heading, Text } from "@chakra-ui/react";
import React from "react";
import { AppButton } from "../components/buttons";
import CenteredCard from "../components/centeredCard";
import { TitleSurnameTextField } from "../components/titleSurnameTextField";
import * as signUpActions from "../redux/signUp";
import { useAppDispatch, useAppSelector } from "../redux/store";

export default function SignUpPage() {
    const dispatch = useAppDispatch();
    const title = useAppSelector(state => state.signUp.title);
    const surname = useAppSelector(state => state.signUp.surname);

    return (
        <CenteredCard>
            <Heading>New Teacher Account</Heading>
            <Text>Please provide us with a few details to get started.</Text>
            <TitleSurnameTextField 
                title={title}
                surname={surname}
                onTitleChange={(newTitle) => dispatch(signUpActions.changeTitle(newTitle))}
                onSurnameChange={(newName) => dispatch(signUpActions.changeSurname(newName))}
            />
            <AppButton onClick={() => dispatch(signUpActions.createAccount())}>Mr.</AppButton>
        </CenteredCard>
    )
}