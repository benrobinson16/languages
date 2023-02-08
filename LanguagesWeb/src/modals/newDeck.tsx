import { Modal, ModalOverlay, ModalContent, ModalHeader, ModalCloseButton, ModalBody, Input, ModalFooter } from "@chakra-ui/react";
import React from "react";
import { AppButton } from "../components/buttons";
import { useAppDispatch, useAppSelector } from "../redux/store";
import * as newDeckActions from "../redux/newDeck";

// Represents the modal that allows the user to create a new deck.
export default function NewDeckModal() {
    const dispatch = useAppDispatch();
    
    // Get data from the store.
    const showModal = useAppSelector(state => state.newDeck.showModal);
    const isLoading = useAppSelector(state => state.newDeck.isLoading);

    // Create a new deck when the user presses enter.
    const onKeyUp = (event: React.KeyboardEvent) => {
        if (event.key === "Enter") {
            dispatch(newDeckActions.createNewDeck());
        }
    }

    return (
        <Modal isOpen={showModal} onClose={() => dispatch(newDeckActions.closeModal())} isCentered>
            <ModalOverlay />
            <ModalContent>
                <ModalHeader>New Deck</ModalHeader>
                <ModalCloseButton />
                <ModalBody>
                    <Input 
                        placeholder="Name" 
                        onChange={newVal => dispatch(newDeckActions.nameChange(newVal.target.value))}
                        onKeyUp={onKeyUp}
                    />
                </ModalBody>
                <ModalFooter>
                    <AppButton onClick={() => dispatch(newDeckActions.createNewDeck())} isLoading={isLoading}>Create</AppButton>
                </ModalFooter>
            </ModalContent>
        </Modal>
    );
}