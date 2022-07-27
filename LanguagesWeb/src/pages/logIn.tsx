import React from "react";
import SignInWithMicrosoftButton from "../components/signInWithMicrosoftButton";

export default function LogInPage() {
    return (
        <div className="bg-light-gray">
            <div className="rounded-lg p-4 bg-white">
                <div className="text-center">
                    <h1>Languages</h1>
                    <p>Teacher platform to assign vocabularly learning homework to classes.</p>
                    <SignInWithMicrosoftButton />
                </div>
            </div>
        </div>
    );
}