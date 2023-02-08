import React from "react";
import { Text, Drawer, DrawerBody, DrawerContent, DrawerFooter, DrawerOverlay, Button, VStack, RadioGroup, Input, Radio, Divider, Heading } from "@chakra-ui/react";
import * as signUpActions from "../redux/signUp";
import { useAppDispatch, useAppSelector } from "../redux/store";

// Provides a form for users to sign up via. Get them to provide a surname and title.
export default function SignUpDrawer() {
    const dispatch = useAppDispatch();

    // Get data from the store.
    const isOpen = useAppSelector(state => state.signUp.showDrawer);
    const title = useAppSelector(state => state.signUp.title);
    const surname = useAppSelector(state => state.signUp.surname);

    // Log changes with the store.
    const close = () => dispatch(signUpActions.hideSignUp());
    const save = () => dispatch(signUpActions.createAccount());
    const onSurnameChange = (newSurname: string) => dispatch(signUpActions.changeSurname(newSurname));
    const onTitleChange = (newTitle: string) => dispatch(signUpActions.changeTitle(newTitle));

    return (
        <Drawer
            isOpen={isOpen}
            placement="right"
            onClose={close}
            size="md"
        >
            <DrawerOverlay />
            <DrawerContent>
                <DrawerBody>
                    <VStack spacing="4" alignItems="left" mt={4}>
                        <Heading size="md">New Teacher Account</Heading>
                        <Text textAlign="left">Please provide us with a few details to get started.</Text>
                        <Divider />
                        <Text textAlign="left" size="md" fontWeight="semibold">Title:</Text>
                        <RadioGroup onChange={onTitleChange} value={title}>
                            <VStack alignItems="left">
                                <Radio value="Mr.">Mr.</Radio>
                                <Radio value="Mrs.">Mrs.</Radio>
                                <Radio value="Ms.">Ms.</Radio>
                                <Radio value="Mx.">Mx.</Radio>
                            </VStack>
                        </RadioGroup>
                        <Divider />
                        <Text textAlign="left" size="md" fontWeight="semibold">Surname:</Text>
                        <Input
                            onChange={(event) => onSurnameChange(event.target.value)}
                            value={surname}
                            placeholder="Surname"
                        />
                    </VStack>
                </DrawerBody>

                <DrawerFooter>
                    <Button variant="outline" onClick={close}>Cancel</Button>
                    <Button colorScheme="blue" ml={2} onClick={save}>Save</Button>
                </DrawerFooter>
            </DrawerContent>
        </Drawer>
    )
}