import { createStandaloneToast } from "@chakra-ui/react";

// Create the toast container. Must be the same instance throughout application, so declared in file here.
export const { ToastContainer, toast } = createStandaloneToast();

export function errorToast(error: any) {
    let message = "An unexpected error ocurred.";

    if (error instanceof Error) {
        message = error.message;
    } else if (typeof error === "string") {
        message = error;
    }

    toast({
        title: "Error",
        description: message,
        status: "error",
        duration: 4000,
        isClosable: true,
    });
}

export function showSuccessToast(message: string) {
    toast({
        title: "Success",
        description: message,
        status: "success",
        duration: 4000,
        isClosable: true
    });
}