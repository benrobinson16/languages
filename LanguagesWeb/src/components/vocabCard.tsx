import React, { useState } from "react";
import { Card, Deck } from "../api/models";
import UICard from "./card";
import { Input } from "@chakra-ui/react";
import * as deckActions from "../redux/deck";
import { useAppDispatch } from "../redux/store";

export default function VocabCard(props: { card: Card, deck: Deck }) {
    const dispatch = useAppDispatch();
    const [englishTerm, setEnglishTerm] = useState(props.card.englishTerm);
    const [foreignTerm, setForeignTerm] = useState(props.card.foreignTerm);

    const save = () => {
        console.log("SAVE");
        dispatch(deckActions.saveCard({
            cardId: props.card.cardId, 
            englishTerm: englishTerm, 
            foreignTerm: foreignTerm,
            difficulty: props.card.difficulty
        }, props.deck));
    };

    return (
        <UICard key={props.card.cardId}>
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
        </UICard>
    );
}