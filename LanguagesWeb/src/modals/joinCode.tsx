import { Modal, ModalOverlay, ModalContent, ModalHeader, ModalCloseButton, ModalBody, Heading } from "@chakra-ui/react";
import { useAppDispatch, useAppSelector } from "../redux/store";
import * as classActions from "../redux/class";

export default function JoinCodeModal() {
    const dispatch = useAppDispatch();
    
    const showModal = useAppSelector(state => state.class.showJoinCode);
    const cla = useAppSelector(state => state.class.class);

    if (cla == null) return <></>;

    return (
        <Modal isOpen={showModal} onClose={() => dispatch(classActions.closeJoinCode())} isCentered>
            <ModalOverlay />
            <ModalContent>
                <ModalHeader>Join Code for <i>{cla.name}</i></ModalHeader>
                <ModalCloseButton />
                <ModalBody>
                    <Heading color="gray.600" size="4xl" marginBottom={8}>{cla.joinCode}</Heading>
                </ModalBody>
            </ModalContent>
        </Modal>
    );
}