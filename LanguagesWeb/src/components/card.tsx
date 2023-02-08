import React from "react";
import {VStack} from "@chakra-ui/react";
import MotionBox from "./motionBox";

// The props for the Card component.
interface CardProps {
    children: React.ReactNode,
    onClick?: () => void,
    background?: string,
    border?: string
}

// A generic card component for displaying a list item.
export default function Card(props: CardProps) {
    if (props.onClick === undefined) {
        return (
            <VStack
                rounded="1rem"
                width="100%"
                align="start"
                padding={4}
                border="1px"
                borderColor={props.border ?? "gray.300"}
                bgColor={props.background ?? "white"}
            >
                {props.children}
            </VStack>
        );
    } else {
        // Onclick defined, so use a motion box to
        // animate hovering with a scale effect.
        return (
            <MotionBox>
                <VStack
                    as="button"
                    onClick={props.onClick}
                    rounded="1rem"
                    width="100%"
                    align="start"
                    padding={4}
                    border="1px"
                    borderColor={props.border ?? "gray.300"}
                    bgColor={props.background ?? "white"}
                >
                    {props.children}
                </VStack>
            </MotionBox>
        );
    }
}