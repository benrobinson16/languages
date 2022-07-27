import React from "react";
import { Button } from "@chakra-ui/react";

interface AppButtonProps {
    children: React.ReactNode,
    onClick: () => void,
    isLoading?: boolean,
    icon?: React.ReactElement,
    loadingText?: string
}

export default function AppButton(props: AppButtonProps) {
    return (
        <Button 
            onClick={props.onClick} 
            isLoading={props.isLoading} 
            leftIcon={props.icon} 
            loadingText={props.loadingText}
            colorScheme="teal" 
            variant="solid"
        >
            {props.children}
        </Button>
    );
}