'use client';

import { AppShell, Burger, Group, Text, NavLink, TextInput, ActionIcon, Stack } from '@mantine/core';
import { useDisclosure } from '@mantine/hooks';
import { IconHome, IconMovie, IconSettings, IconUser, IconSearch, IconLogout } from '@tabler/icons-react';
import { usePathname, useRouter } from 'next/navigation';
import { useAuth } from '../context/AuthProvider';
import { BottomNav } from './BottomNav';

interface AppLayoutProps {
    children: React.ReactNode;
}

export function AppLayout({ children }: AppLayoutProps) {
    const [opened, { toggle }] = useDisclosure();
    const pathname = usePathname();
    const router = useRouter();
    const { isAuthenticated, logout } = useAuth();

    const navItems = [
        { icon: IconHome, label: '홈', href: '/' },
        { icon: IconMovie, label: '영화', href: '#' },
        // Conditional item based on auth state
        {
            icon: IconUser,
            label: isAuthenticated ? '프로필' : '로그인',
            href: isAuthenticated ? '/profile' : '/login'
        },
        { icon: IconSettings, label: '설정', href: '/settings' },
    ];

    return (
        <AppShell
            header={{ height: 70 }}
            navbar={{
                width: 250,
                breakpoint: 'sm',
                collapsed: { mobile: true }, // Always collapsed on mobile if we use BottomNav
                // Or: collapsed: { mobile: !opened }, but if we want BottomNav, we usually disable Sidebar on mobile.
                // Let's set it to always hidden on mobile for this design.
            }}
            padding="md"
        >
            <AppShell.Header>
                <Group h="100%" px="md" justify="space-between">
                    <Group>
                        <Burger opened={opened} onClick={toggle} hiddenFrom="sm" size="sm" />
                        <Text
                            size="xl"
                            fw={900}
                            variant="gradient"
                            gradient={{ from: 'red', to: 'orange', deg: 90 }}
                            style={{ cursor: 'pointer' }}
                            onClick={() => router.push('/')}
                        >
                            AudioView
                        </Text>
                    </Group>
                    <Group>
                        <TextInput
                            placeholder="검색어를 입력하세요"
                            leftSection={<IconSearch size={16} />}
                            radius="xl"
                            w={300}
                            visibleFrom="sm"
                        />
                        <ActionIcon
                            variant="light"
                            size="lg"
                            radius="xl"
                            onClick={() => router.push(isAuthenticated ? '/profile' : '/login')}
                        >
                            <IconUser size={20} />
                        </ActionIcon>
                        {isAuthenticated && (
                            <ActionIcon
                                variant="subtle"
                                color="gray"
                                size="lg"
                                radius="xl"
                                onClick={logout}
                                title="로그아웃"
                            >
                                <IconLogout size={20} />
                            </ActionIcon>
                        )}
                    </Group>
                </Group>
            </AppShell.Header>

            <AppShell.Navbar p="md" hiddenFrom="sm">
                <Stack gap="xs">
                    {navItems.map((item) => (
                        <NavLink
                            key={item.label}
                            active={pathname === item.href}
                            label={item.label}
                            leftSection={<item.icon size={20} stroke={1.5} />}
                            onClick={() => router.push(item.href)}
                            variant="light"
                            color="violet"
                            style={{ borderRadius: 8 }}
                        />
                    ))}
                </Stack>
            </AppShell.Navbar>

            <AppShell.Main pb={80}>
                {children}
            </AppShell.Main>

            <BottomNav />
        </AppShell>
    );
}
