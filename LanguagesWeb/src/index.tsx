import React from 'react';
import ReactDOM from 'react-dom/client';
import { Provider } from 'react-redux';
import store from "./redux/store";
import Nav from './pages/nav';
import { ChakraProvider } from '@chakra-ui/react';
import { ToastContainer } from './helper/toast';

const rootElement = document.getElementById('root')!;
const root = ReactDOM.createRoot(rootElement);

root.render(
    <React.StrictMode>
        <ChakraProvider>
            <Provider store={store}>
                <Nav />
                <ToastContainer />
            </Provider>
        </ChakraProvider>
    </React.StrictMode>
);