import { Button, Icon } from "@chakra-ui/react";
import React from "react";
import { HiOutlineLogout, HiArrowSmLeft, HiOutlineHome } from "react-icons/hi";
import authService from "../services/authService";
import signInImage from "../assets/signInWithMicrosoft.svg";
import { logIn } from "../redux/auth";
import { useAppDispatch } from "../redux/store";
import { back, popToHome } from "../redux/nav";

// The props for the AppButton component.
interface AppButtonProps {
    children: React.ReactNode,
    onClick: () => void,
    isLoading?: boolean,
    icon?: React.ReactElement,
    loadingText?: string
}

// A styled button that is used throughout the app.
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

// A styled button that is used throughout the app 
// for indicating a deletion.
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

// The branded Sign In with Microsoft button.
export function SignInWithMicrosoftButton() {
    const dispatch = useAppDispatch();

    return (
        <button onClick={() => dispatch(logIn())}>
            <img src={signInImage} alt="Sign In" />
        </button>
    );
}

// The Sign Out button for display in the top corner.
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

// The back navigation button which opens the previous page.
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

// The home navigation button which always opens the home page.
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
