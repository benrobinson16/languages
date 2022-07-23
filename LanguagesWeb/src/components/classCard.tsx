import React from "react";
import {Class} from "../api/models";
import Card from "./card";

export default function ClassCard(props: {class: Class}) {
    return (
        <Card>
            <p className="3xl blue">{props.class.name}</p>
        </Card>
    );
}