import React, { useEffect } from "react";
import { Select, SingleValue } from "chakra-react-select";
import { useAppDispatch, useAppSelector } from "../redux/store";
import { Input } from "@chakra-ui/react";
import * as summaryActions from "../redux/summary";

export function ClassField(props: { name: string, onChange: (id: number | null) => void }) {
    const dispatch = useAppDispatch();
    const classes = useAppSelector(state => state.summary.classes);

    useEffect(() => {
        if (classes == null) {
            dispatch(summaryActions.loadSummary());
        }
    }, [classes, dispatch]);

    if (classes == null) {
        return <Input placeholder={props.name} isDisabled />;
    }

    return (
        <div style={{width: "100%"}}>
            <Select 
                placeholder={props.name}
                name={props.name}
                onChange={(e) => props.onChange(e == null ? null : e.value)}
                options={classes.map(c => ({ label: c.name, value: c.id }))}
                menuPlacement="auto"
                menuPosition="fixed"
            />
        </div>
    )
}

export function DeckField(props: { name: string, onChange: (id: number | null) => void }) {
    const dispatch = useAppDispatch();
    const decks = useAppSelector(state => state.summary.decks);

    useEffect(() => {
        if (decks == null) {
            dispatch(summaryActions.loadSummary());
        }
    }, [decks, dispatch]);

    if (decks == null) {
        return <Input placeholder={props.name} isDisabled />;
    }

    const change = (e: SingleValue<{label: string, value: number}>) => {
        props.onChange(e == null ? null : e.value);
    };

    return (
        <div style={{width: "100%"}}>
            <Select 
                placeholder={props.name}
                name={props.name}
                onChange={change}
                options={decks.map(d => ({ label: d.name, value: d.deckId }))}
                menuPlacement="auto"
                menuPosition="fixed"
            />
        </div>
    )
}