import React, { useState } from "react";
import { Card, Deck } from "../api/models";
import UICard from "./card";
import { HStack, Input, VStack, Icon, Button } from "@chakra-ui/react";
import * as deckActions from "../redux/deck";
import { useAppDispatch } from "../redux/store";
import { FiTrash2, FiCopy } from "react-icons/fi";

export default function VocabCard(props: { card: Card, deck: Deck }) {
    const dispatch = useAppDispatch();
    const [englishTerm, setEnglishTerm] = useState(props.card.englishTerm); // State with default value
    const [foreignTerm, setForeignTerm] = useState(props.card.foreignTerm); // State with default value

    const save = () => {
        dispatch(deckActions.saveCard({
            cardId: props.card.cardId, 
            englishTerm: englishTerm, 
            foreignTerm: foreignTerm,
            difficulty: props.card.difficulty
        }, props.deck));
    };

    const deleteCard = () => {
        dispatch(deckActions.deleteCard(props.card.cardId));
    };

    const copyCard = () => {
        dispatch(deckActions.copyCard(props.card, props.deck));
    }

    return (
        <UICard key={props.card.cardId}>
            <HStack width="100%" gap={4}>
                <VStack width="100%">
                    <Input
                        onChange={(event) => setEnglishTerm(event.target.value)}
                        onSubmit={save}
                        onBlur={save}
                        value={englishTerm}
                        placeholder="English..."
                        variant="flushed"
                    />
                    <Input
                        onChange={(event) => setForeignTerm(event.target.value)}
                        onSubmit={save}
                        onBlur={save}
                        value={foreignTerm}
                        placeholder="French..."
                        variant="flushed"
                    />
                </VStack>
                <VStack>
                    <Button onClick={copyCard}>
                        <Icon as={FiCopy} />
                    </Button>
                    <Button onClick={deleteCard}>
                        <Icon as={FiTrash2} color="red" />
                    </Button>
                </VStack>
            </HStack>
        </UICard>
    );
}