import { VStack, SimpleGrid, Spinner, UnorderedList, Text, ListItem, Flex, Button, Spacer } from "@chakra-ui/react";
import React, { useEffect } from "react";
import { CardList } from "../components/entityList";
import { useAppDispatch, useAppSelector } from "../redux/store";
import * as deckActions from "../redux/deck";
import UICard from "../components/card";
import EditableHeading from "../components/editableHeading";

export default function DeckPage(props: { id: number }) {
    const dispatch = useAppDispatch();

    const isLoading = useAppSelector(state => state.deck.isLoading);
    
    const deck = useAppSelector(state => state.deck.deck);
    const cards = useAppSelector(state => state.deck.cards);

    useEffect(() => {
        dispatch(deckActions.loadDeckDetails(props.id));
    }, [dispatch, props.id]);

    if (isLoading || deck == null || cards == null) {
        return <Spinner />;
    }

    return (
        <VStack width="100vw" padding={8} spacing={8}>
            <Flex width="100%">
                <EditableHeading initialValue={deck.name} onSave={(value) => dispatch(deckActions.editDeckName(props.id, value))} />
                <Spacer />
                <Button onClick={() => dispatch(deckActions.deleteDeck(props.id))}>Delete</Button>
            </Flex>
            <SimpleGrid width="100%" columns={2} gap={8}>
                <CardList cards={cards} deck={deck} />
                <div>
                    <UICard>
                            <Text textAlign="left" width="100%">Creating multiple valid responses for a card is easy. Simply follow the following rules:</Text>
                            <UnorderedList paddingLeft="1.25rem" spacing={2}>
                                <ListItem>Provide alternative responses with a slash, for example "3/three".</ListItem>
                                <ListItem>Group an alternative response using square brackets if it is more than one word, for example "[le chien]/[un chat]"</ListItem>
                                <ListItem>Provide optional content in brackets, for example "vert(e)".</ListItem>
                                <ListItem>Articles are automatically detected and excluded from marking unless the gender (if applicable) is wrong.</ListItem>
                            </UnorderedList>
                    </UICard>
                </div>
            </SimpleGrid>
        </VStack>
    );
}
