import { VStack, Heading, SimpleGrid, Spinner, Input, UnorderedList, Text, ListItem } from "@chakra-ui/react";
import React, { useEffect } from "react";
import { AppButton } from "../components/buttons";
import { CardList, EntityList, ProgressList } from "../components/entityList";
import MotionBox from "../components/motionBox";
import * as nav from "../redux/nav";
import { useAppDispatch, useAppSelector } from "../redux/store";
import * as deckActions from "../redux/deck";
import UICard from "../components/card";

export default function DeckPage(props: { id: number }) {
    const dispatch = useAppDispatch();

    const isLoading = useAppSelector(state => state.deck.isLoading);
    const isSaving = useAppSelector(state => state.deck.isSaving);
    
    const deck = useAppSelector(state => state.deck.deck);
    const cards = useAppSelector(state => state.deck.cards);

    useEffect(() => {
        dispatch(deckActions.loadDeckDetails(props.id));
    }, [dispatch, props.id]);

    if (isLoading || deck == null || cards == null) {
        return <Spinner />;
    }

    return (
        <VStack width={"100%"} padding={8} spacing={8}>
            <Heading width="100%" textAlign="left">{deck.name}</Heading>
            <SimpleGrid width="100%" columns={2} gap={8}>
                <CardList cards={cards} deck={deck} />
                <div>
                    <UICard>
                            <Text width="100%" textAlign="left">Creating multiple valid responses for a card is easy. Simply follow the following rules:</Text>
                            <UnorderedList paddingLeft="1.25rem" spacing={2}>
                                <ListItem>Separate different responses with a slash, for example "3 / three".</ListItem>
                                <ListItem>Provide optional content in brackets, for example "vert(e)".</ListItem>
                                <ListItem>Articles are automatically detected and excluded from marking unless the gender (if applicable) is wrong.</ListItem>
                            </UnorderedList>
                    </UICard>
                </div>
            </SimpleGrid>
        </VStack>
    );
}
