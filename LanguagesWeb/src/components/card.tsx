import React from "react";

export default function Card(props: {children: React.ReactNode}): React.ReactNode {
    return (
        <div className="border-1 p-4">
            {props.children}
        </div>
    );
}