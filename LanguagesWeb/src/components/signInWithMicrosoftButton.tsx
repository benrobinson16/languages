import React from "react";
import signInImage from "../assets/signInWithMicrosoft.svg";
import { getToken } from "../redux/auth";
import { useAppDispatch } from "../redux/store";

export default function SignInWithMicrosoftButton() {
    const dispatch = useAppDispatch();

    const logIn = () => {
        console.log("HELLO");
        dispatch(getToken());
    };

    return (
        <button onClick={logIn}>
            <img src={signInImage} />
        </button>
    );
}