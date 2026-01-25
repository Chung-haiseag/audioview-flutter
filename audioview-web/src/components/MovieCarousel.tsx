import { Carousel } from '@mantine/carousel';
import { Title, Stack, ThemeIcon } from '@mantine/core';
import { MovieCard, MovieCardProps } from './MovieCard';
import { IconChevronRight } from '@tabler/icons-react';

interface MovieCarouselProps {
    title: string;
    movies: MovieCardProps['movie'][];
}

export function MovieCarousel({ title, movies }: MovieCarouselProps) {
    return (
        <Stack gap="md" py="md">
            <Title
                order={3}
                pl="md"
                style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '8px',
                    cursor: 'pointer'
                }}
            >
                {title}
                <ThemeIcon variant="transparent" color="gray" size="sm">
                    <IconChevronRight />
                </ThemeIcon>
            </Title>
            <Carousel
                slideSize={{ base: '35%', sm: '25%', md: '20%', lg: '15%' }} // Mobile-first sizing
                slideGap="sm"
                withControls={false} // Hidden on mobile, could show on hover for desktop
                style={{ paddingLeft: 'calc(var(--mantine-spacing-md) - 5px)' }} // Visual alignment
            >
                {movies.map((movie) => (
                    <Carousel.Slide key={movie.id}>
                        <MovieCard movie={movie} />
                    </Carousel.Slide>
                ))}
            </Carousel>
        </Stack>
    );
}
