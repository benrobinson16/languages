// Helper function to get an error message from an error object.
export function extractErrorMessage(error: any): string {
    if (error instanceof Error) {
        return error.message;
    } else if (typeof error === "string") {
        return error;
    }

    return "An unexpected error ocurred. Please try again.";
}