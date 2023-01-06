import { Modal, ModalOverlay, ModalContent, ModalHeader, ModalCloseButton, ModalBody, ModalFooter, VStack, Text } from "@chakra-ui/react";
import React from "react";
import { AppButton } from "../components/buttons";
import { useAppDispatch, useAppSelector } from "../redux/store";
import * as newTaskActions from "../redux/newTask";
import { ClassField, DeckField } from "../components/autocompleteField";
import DatePicker from "../components/datePicker";

export default function NewTaskModal() {
    const dispatch = useAppDispatch();
    
    const showModal = useAppSelector(state => state.newTask.showModal);
    const isLoading = useAppSelector(state => state.newTask.isLoading);
    const classEditable = useAppSelector(state => state.newTask.classEditable);

    let classField = null;
    if (classEditable) {
        classField = (
            <>
                <Text textAlign="left">Class:</Text>
                <ClassField 
                    name="Class"
                    onChange={(id) => dispatch(newTaskActions.selectedClass(id))}
                />
                <br />
            </>
        );
    }

    return (
        <Modal isOpen={showModal} onClose={() => dispatch(newTaskActions.closeModal())} isCentered>
            <ModalOverlay />
            <ModalContent>
                <ModalHeader>New Task</ModalHeader>
                <ModalCloseButton />
                <ModalBody>
                    <VStack spacing={2} width="100%" alignItems="start">
                        {classField}
                        <Text textAlign="left">Deck:</Text>
                        <DeckField 
                            name="Deck"
                            onChange={(id) => dispatch(newTaskActions.selectedDeck(id))}
                        />
                        <br />
                        <Text textAlign="left">Due Date:</Text>
                        <DatePicker onChange={d => dispatch(newTaskActions.changedDate(d.valueOf()))} />
                    </VStack>
                </ModalBody>
                <ModalFooter>
                    <AppButton onClick={() => dispatch(newTaskActions.createNewTask())} isLoading={isLoading}>Create</AppButton>
                </ModalFooter>
            </ModalContent>
        </Modal>
    );
}