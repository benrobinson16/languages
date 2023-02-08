import React from "react";
import { Box } from "@chakra-ui/react";
import { motion } from "framer-motion";

const MotionBoxComponent = motion(Box);

// Define the variations of the motion box for hover.
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

// Creates the motion box component.
export default function MotionBox(props: { children: React.ReactNode, maxWidth?: boolean, justifySelf?: string }) {
    return (
        <MotionBoxComponent
            initial="rest"
            whileHover="hover"
            animate="rest"
            variants={variants}
            width={props.maxWidth === undefined ? "100%" : (props.maxWidth ? "100%" : "fit-content")}
            justifySelf={props.justifySelf}
        >
            {props.children}
        </MotionBoxComponent>
    )
}
