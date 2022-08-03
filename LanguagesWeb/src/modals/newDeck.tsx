import { Modal, ModalOverlay, ModalContent, ModalHeader, ModalCloseButton, ModalBody, Input, ModalFooter } from "@chakra-ui/react";
import React from "react";
import { AppButton } from "../components/buttons";
import { useAppDispatch, useAppSelector } from "../redux/store";
import * as newDeckActions from "../redux/newDeck";

export default function NewDeckModal() {
    const dispatch = useAppDispatch();
    
    const showModal = useAppSelector(state => state.newDeck.showModal);
    const isLoading = useAppSelector(state => state.newDeck.isLoading);

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