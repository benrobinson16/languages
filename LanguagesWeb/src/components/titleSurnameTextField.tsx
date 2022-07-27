import { Input, Radio, RadioGroup, Stack } from "@chakra-ui/react";
import React from "react";

interface TitleSurnameTextField {
    title: string,
    surname: string,
    onTitleChange: (nextValue: string) => void,
    onSurnameChange: (nextValue: string) => void,
}

export function TitleSurnameTextField(props: TitleSurnameTextField) {
    return (
        <Stack spacing={4}>
            <RadioGroup onChange={props.onTitleChange} value={props.title}>
                <Stack direction="row">
                    <Radio value="Mr." />
                    <Radio value="Mrs." />
                    <Radio value="Ms." />
                    <Radio value="Mx." />
                </Stack>
            </RadioGroup>
            <Input
                onChange={(event) => props.onSurnameChange(event.target.value)}
                value={props.surname}
                placeholder="Surname"
            />
        </Stack>
    );
}