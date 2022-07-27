import React from "react";
import CenteredCard from "../components/centeredCard";
import SignInWithMicrosoftButton from "../components/signInWithMicrosoftButton";
import { openHome, openSignUp } from "../redux/nav";
import { useAppDispatch, useAppSelector } from "../redux/store";

export default function LogInPage() {
    const dispatch = useAppDispatch();
    const token = useAppSelector(state => state.auth.token);
    const user = useAppSelector(state => state.auth.user);

    if (token != null && user != null) {
        // Signed in and account already exists.
        dispatch(openHome());
    } else if (token != null) {
        // Signed in but account does not exist.
        dispatch(openSignUp());
    }

    return (
        <CenteredCard>
            <div className="text-center">
                <h1>Languages</h1>
                <p>Teacher platform to assign vocabularly learning homework to classes.</p>
                <SignInWithMicrosoftButton />
            </div>
        </CenteredCard>
    );
}