'use client';

import { Container, Title, Text, Button, Paper, Avatar, Group, Stack } from '@mantine/core';
import { useAuth } from '../../context/AuthProvider';
import { useEffect } from 'react';
import { useRouter } from 'next/navigation';

export default function ProfilePage() {
    const { isAuthenticated, logout } = useAuth();
    const router = useRouter();

    useEffect(() => {
        if (!isAuthenticated) {
            router.push('/login');
        }
    }, [isAuthenticated, router]);

    if (!isAuthenticated) {
        return null; // Or a loading spinner
    }

    return (
        <Container size="sm" py="xl">
            <Paper radius="md" withBorder p="lg" bg="var(--mantine-color-body)">
                <Group>
                    <Avatar
                        src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=250&q=80"
                        size={120}
                        radius={120}
                        mx="auto"
                    />
                    <Stack gap={5}>
                        <Text fz="lg" fw={500}>
                            테스트 유저
                        </Text>
                        <Text c="dimmed" fz="sm">
                            testuser@audioview.com
                        </Text>
                        <Text c="dimmed" fz="sm">
                            Premium 회원
                        </Text>
                    </Stack>
                </Group>

                <Button
                    variant="light"
                    color="red"
                    fullWidth
                    mt="md"
                    radius="md"
                    onClick={logout}
                >
                    로그아웃
                </Button>
            </Paper>
        </Container>
    );
}
