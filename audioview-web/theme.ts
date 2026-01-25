import { createTheme, virtualColor, rem } from '@mantine/core';

export const theme = createTheme({
    primaryColor: 'violet',
    defaultRadius: 'md',
    fontFamily: 'Inter, sans-serif',
    colors: {
        dark: [
            '#C1C2C5',
            '#A6A7AB',
            '#909296',
            '#5c5f66',
            '#373A40',
            '#2C2E33',
            '#25262B',
            '#1A1B1E',
            '#141517',
            '#101113',
        ],
    },
    components: {
        Button: {
            defaultProps: {
                size: 'md',
                fw: 600,
            },
        },
        Card: {
            defaultProps: {
                shadow: 'sm',
                padding: 'lg',
                radius: 'md',
                withBorder: true,
            },
        },
    },
});
