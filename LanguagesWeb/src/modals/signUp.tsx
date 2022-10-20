import React from "react";
import { Text, Drawer, DrawerBody, DrawerContent, DrawerFooter, DrawerOverlay, DrawerHeader, Button } from "@chakra-ui/react";
import { TitleSurnameTextField } from "../components/titleSurnameTextField";
import * as signUpActions from "../redux/signUp";
import { useAppDispatch, useAppSelector } from "../redux/store";
import authService from "../services/authService";

export default function SignUpPage() {
    const dispatch = useAppDispatch();
    const title = useAppSelector(state => state.signUp.title);
    const surname = useAppSelector(state => state.signUp.surname);

    const close = () => authService.logOutRedirect();
    const save = () => dispatch(signUpActions.createAccount());
    const isOpen = useAppSelector(state => state.signUp.showDrawer);

    return (
        <Drawer
            isOpen={isOpen}
            placement="right"
            onClose={close}
        >
            <DrawerOverlay />
            <DrawerContent>
                <DrawerHeader>New Teacher Account</DrawerHeader>

                <DrawerBody>
                    <Text>Please provide us with a few details to get started.</Text>
                    <TitleSurnameTextField 
                        title={title}
                        surname={surname}
                        onTitleChange={(newTitle) => dispatch(signUpActions.changeTitle(newTitle))}
                        onSurnameChange={(newName) => dispatch(signUpActions.changeSurname(newName))}
                    />
                </DrawerBody>

                <DrawerFooter>
                    <Button variant="outline" onClick={close}>Cancel</Button>
                    <Button colorScheme="blue" ml={2} onClick={save}>Save</Button>
                </DrawerFooter>
            </DrawerContent>
        </Drawer>
    )
}