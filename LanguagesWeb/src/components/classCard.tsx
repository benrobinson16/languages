import React from "react";
import {Class} from "../api/models";
import Card from "./card";
import {Text} from "@chakra-ui/react";

export default function ClassCard(props: {class: Class}) {
    return (
        <Card>
            <Text>{props.class.name}</Text>
            <Text>{props.class.numActiveTasks} active tasks</Text>
        </Card>
    );
}