import { Paper, Group, ActionIcon, Text, Stack } from '@mantine/core';
import { IconHome, IconMovie, IconUser, IconSettings, IconLogout } from '@tabler/icons-react';
import { useRouter, usePathname } from 'next/navigation';
import { useAuth } from '@/context/AuthProvider';

export function BottomNav() {
    const router = useRouter();
    const pathname = usePathname();
    const { isAuthenticated, logout } = useAuth();

    const navItems = [
        { icon: IconHome, label: '홈', href: '/' },
        { icon: IconMovie, label: '영화', href: '#' },
        {
            icon: IconUser,
            label: isAuthenticated ? '프로필' : '로그인',
            href: isAuthenticated ? '/profile' : '/login'
        },
        { icon: IconSettings, label: '설정', href: '/settings' },
    ];

    return (
        <Paper
            shadow="lg"
            radius={0}
            style={{
                position: 'fixed',
                bottom: 0,
                left: 0,
                right: 0,
                zIndex: 200,
                borderTop: '1px solid var(--mantine-color-dark-4)',
                backgroundColor: 'rgba(26, 27, 30, 0.95)', // Semi-transparent
                backdropFilter: 'blur(10px)',
            }}
            hiddenFrom="sm" // Only visible on mobile
        >
            <Group justify="space-around" align="center" py="xs" gap={0}>
                {navItems.map((item) => {
                    const isActive = pathname === item.href;
                    return (
                        <ActionIcon
                            key={item.label}
                            variant="subtle"
                            color={isActive ? 'violet' : 'gray'}
                            size="xl"
                            h="auto" // Allow height to grow for stack
                            onClick={() => router.push(item.href)}
                            style={{ flex: 1 }}
                        >
                            <Stack align="center" gap={4} py={4}>
                                <item.icon size={24} stroke={isActive ? 2 : 1.5} />
                                <Text size="xs" fw={isActive ? 600 : 400}>
                                    {item.label}
                                </Text>
                            </Stack>
                        </ActionIcon>
                    );
                })}
            </Group>
        </Paper>
    );
}
