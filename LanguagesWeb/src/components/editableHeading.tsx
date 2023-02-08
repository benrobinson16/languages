import React from "react";
import { Button, Editable, Tooltip, EditablePreview, Input, EditableInput, Heading, HStack } from "@chakra-ui/react";

// Saves the value of an editable heading. Visible only when editing.
function SaveControl(props: { isEditing: boolean, onSubmit: () => void }) {
    if (props.isEditing) {
        return (
            <Button 
                colorScheme="blue" 
                variant="solid"
                onClick={props.onSubmit}
            >
                Save
            </Button>
        );
    } else {
        return null;
    }
}

// A heading that becomes editable when clicked.
export default function EditableHeading(props: { initialValue: string, onSave: (value: string) => void }) {
    return (
        <Editable
            defaultValue={props.initialValue}
            isPreviewFocusable={true}
            submitOnBlur={true}
            width="100%"
            onSubmit={(value) => props.onSave(value)}
        >
            {props => (
                <>
                    <Tooltip label="Click to edit name" borderRadius={8}>
                        <Heading alignSelf="start" as={EditablePreview} />
                    </Tooltip>
                    <HStack marginRight={2}>
                        <Input width="100%" as={EditableInput} />
                        <SaveControl {...props} />
                    </HStack>
                </>
            )}
        </Editable>
    );
}