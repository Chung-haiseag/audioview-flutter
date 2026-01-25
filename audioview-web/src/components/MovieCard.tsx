'use client';

import { Card, Image, Text, Group, Badge, Stack } from '@mantine/core';
import { useState } from 'react';

interface MovieCardProps {
    movie: {
        id: string;
        title: string;
        year: number;
        genres: string[];
        posterUrl: string;
        hasAD: boolean;
        hasCC: boolean;
    };
}

export function MovieCard({ movie }: MovieCardProps) {
    const [imgSrc, setImgSrc] = useState(movie.posterUrl);

    return (
        <Card
            shadow="sm"
            padding="none"
            radius="md"
            withBorder={false}
            style={{ cursor: 'pointer', backgroundColor: 'transparent' }}
        >
            <Card.Section>
                <Image
                    src={imgSrc}
                    h={320}
                    alt={movie.title}
                    onError={() => setImgSrc('https://placehold.co/300x450?text=No+Image')}
                    fallbackSrc="https://placehold.co/300x450?text=No+Image"
                />
            </Card.Section>
            <Stack mt="sm" gap={4}>
                <Text fw={700} truncate>{movie.title}</Text>
                <Group gap={4}>
                    {movie.hasAD && <Badge size="xs" variant="outline" color="blue">AD</Badge>}
                    {movie.hasCC && <Badge size="xs" variant="outline" color="gray">CC</Badge>}
                    <Text size="xs" c="dimmed">
                        {movie.year} • {movie.genres[0]}
                    </Text>
                </Group>
            </Stack>
        </Card>
    );
}
