import { Input } from "@chakra-ui/react";
import React, { useState } from "react";

export default function DatePicker(props: { date?: Date, onChange: (date: Date) => void }) {
    const [localDate, setLocalDate] = useState(props.date);

    return (
        <Input 
            placeholder="Select Date and Time"
            size="md"
            type="datetime-local" 
            value={(localDate ?? new Date()).toISOString().split('.')[0]} 
            onChange={newVal => {
                const newDate = new Date(newVal.target.value);
                setLocalDate(newDate);
                props.onChange(newDate);
            }}
        />
    );
}