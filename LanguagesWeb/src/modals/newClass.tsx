import { Modal, ModalOverlay, ModalContent, ModalHeader, ModalCloseButton, ModalBody, Input, ModalFooter } from "@chakra-ui/react";
import React from "react";
import { AppButton } from "../components/buttons";
import { useAppDispatch, useAppSelector } from "../redux/store";
import * as newClassActions from "../redux/newClass";

export default function NewClassModal() {
    const dispatch = useAppDispatch();
    
    const showModal = useAppSelector(state => state.newClass.showModal);
    const isLoading = useAppSelector(state => state.newClass.isLoading);

    const onKeyUp = (event: React.KeyboardEvent) => {
        if (event.key === "Enter") {
            dispatch(newClassActions.createNewClass());
        }
    }

    return (
        <Modal isOpen={showModal} onClose={() => dispatch(newClassActions.closeModal())} isCentered>
            <ModalOverlay />
            <ModalContent>
                <ModalHeader>New Class</ModalHeader>
                <ModalCloseButton />
                <ModalBody>
                    <Input 
                        placeholder="Name" 
                        onChange={newVal => dispatch(newClassActions.nameChange(newVal.target.value))}
                        onKeyUp={onKeyUp}
                    />
                </ModalBody>
                <ModalFooter>
                    <AppButton onClick={() => dispatch(newClassActions.createNewClass())} isLoading={isLoading}>Create</AppButton>
                </ModalFooter>
            </ModalContent>
        </Modal>
    );
}