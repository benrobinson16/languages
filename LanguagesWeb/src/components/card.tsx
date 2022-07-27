import React from "react";
import {Box, Heading, Text, VStack} from "@chakra-ui/react";
import {motion} from "framer-motion";

const MotionBox = motion(Box);

const variants = {
    rest: {
        scale: 1.0,
        transition: {
            duration: 0.5,
            type: "tween",
            ease: "easeOut"
        }
    },
    hover: {
        scale: 1.02,
        transition: {
            duration: 0.5,
            type: "tween",
            ease: "easeOut"
        }
    }
}

interface CardProps {
    children: React.ReactNode;
    onClick?: () => void;
}

export default function Card(props: CardProps) {
    return (
        <MotionBox
            initial="rest"
            whileHover="hover"
            animate="rest"
            variants={variants}
            width="100%"
        >
            <VStack
                as="button"
                onClick={props.onClick}
                rounded="1rem"
                width="100%"
                align="start"
                padding={8}
                border="1px"
                borderColor="gray.300"
            >
                {props.children}
            </VStack>
        </MotionBox>
    );
}