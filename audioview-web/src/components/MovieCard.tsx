import { Card, Image, Text, Stack, Badge, Group, Overlay } from '@mantine/core';
import { useState } from 'react';

// Define the interface for Movie data
interface Movie {
    id: number;
    title: string;
    posterUrl: string;
    year: number;
    genres: string[];
    hasAD: boolean;
    hasCC: boolean;
}

export interface MovieCardProps {
    movie: Movie;
}

export function MovieCard({ movie }: MovieCardProps) {
    const [imgSrc, setImgSrc] = useState(movie.posterUrl);
    const [hovered, setHovered] = useState(false);

    return (
        <Card
            shadow="sm"
            padding={0}
            radius="md"
            withBorder={false}
            style={{
                cursor: 'pointer',
                backgroundColor: 'transparent',
                transition: 'transform 0.2s ease',
                transform: hovered ? 'scale(1.05)' : 'scale(1)',
                position: 'relative'
            }}
            onMouseEnter={() => setHovered(true)}
            onMouseLeave={() => setHovered(false)}
        >
            <Card.Section style={{ position: 'relative' }}>
                <Image
                    src={imgSrc}
                    h={320} // Fixed height or aspect ratio could be better but sticking to previous height for now
                    // For a true carousel, we might want aspect-ratio
                    style={{ objectFit: 'cover', aspectRatio: '2/3' }}
                    alt={movie.title}
                    onError={() => setImgSrc('https://placehold.co/300x450?text=No+Image')}
                    fallbackSrc="https://placehold.co/300x450?text=No+Image"
                />
                {/* Dark Gradient Overlay at the bottom for text readability if we overlay text */}
                <Overlay
                    gradient="linear-gradient(180deg, rgba(0, 0, 0, 0) 50%, rgba(0, 0, 0, 0.8) 100%)"
                    opacity={0.8}
                    zIndex={1}
                />

                {/* Badges on top of image */}
                <Group gap={4} style={{ position: 'absolute', top: 8, right: 8, zIndex: 2 }}>
                    {movie.hasAD && <Badge size="xs" variant="filled" color="yellow.8" c="black">AD</Badge>}
                    {movie.hasCC && <Badge size="xs" variant="filled" color="gray.2" c="black">CC</Badge>}
                </Group>
            </Card.Section>

            <Stack gap={2} mt={8}>
                <Text fw={600} size="sm" truncate c="gray.1">
                    {movie.title}
                </Text>
                <Text size="xs" c="dimmed">
                    {movie.year} • {movie.genres[0]}
                </Text>
            </Stack>
        </Card>
    );
}
