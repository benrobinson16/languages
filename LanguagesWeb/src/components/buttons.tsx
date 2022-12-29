import { Button, Icon } from "@chakra-ui/react";
import React from "react";
import { HiOutlineLogout, HiArrowSmLeft, HiOutlineHome } from "react-icons/hi";
import authService from "../services/authService";
import signInImage from "../assets/signInWithMicrosoft.svg";
import { logIn } from "../redux/auth";
import { useAppDispatch } from "../redux/store";
import { back, popToHome } from "../redux/nav";

interface AppButtonProps {
    children: React.ReactNode,
    onClick: () => void,
    isLoading?: boolean,
    icon?: React.ReactElement,
    loadingText?: string
}

export function AppButton(props: AppButtonProps) {
    return (
        <Button 
            onClick={props.onClick} 
            isLoading={props.isLoading} 
            leftIcon={props.icon} 
            loadingText={props.loadingText}
            colorScheme="blue" 
            variant="solid"
        >
            {props.children}
        </Button>
    );
}

export function DestructiveButton(props: AppButtonProps) {
    return (
        <Button 
            onClick={props.onClick} 
            isLoading={props.isLoading} 
            leftIcon={props.icon} 
            loadingText={props.loadingText}
            colorScheme="red" 
            variant="solid"
        >
            {props.children}
        </Button>
    );
}

export function SignInWithMicrosoftButton() {
    const dispatch = useAppDispatch();

    return (
        <button onClick={() => dispatch(logIn())}>
            <img src={signInImage} alt="Sign In" />
        </button>
    );
}

export function SignOutButton() {
    return (
        <Button
            rightIcon={<Icon as={HiOutlineLogout} />}
            onClick={() => authService.logOutRedirect()}
        >
            Sign Out
        </Button>
    )
}

export function BackButton() {
    const dispatch = useAppDispatch();

    return (
        <Button
            leftIcon={<Icon as={HiArrowSmLeft} />}
            onClick={() => dispatch(back())}
        >
            Back
        </Button>
    )
}

export function HomeButton() {
    const dispatch = useAppDispatch();

    return (
        <Button
            leftIcon={<Icon as={HiOutlineHome} />}
            onClick={() => dispatch(popToHome())}
        >
            Home
        </Button>
    )
}
