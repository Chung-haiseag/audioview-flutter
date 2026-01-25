'use client';

import { TextInput, PasswordInput, Checkbox, Anchor, Paper, Title, Text, Container, Group, Button, Stack } from '@mantine/core';
import { useAuth } from '../../context/AuthProvider';

export default function LoginPage() {
    const { login } = useAuth();

    const handleLogin = () => {
        login();
    };

    return (
        <Container size={420} my={40}>
            <Title ta="center" fw={900}>
                AudioView
            </Title>
            <Text c="dimmed" size="sm" ta="center" mt={5}>
                로그인하여 더 많은 콘텐츠를 즐기세요
            </Text>

            <Paper withBorder shadow="md" p={30} mt={30} radius="md">
                <Stack>
                    <TextInput label="이메일 / 아이디" placeholder="you@example.com" required />
                    <PasswordInput label="비밀번호" placeholder="비밀번호를 입력하세요" required />
                    <Group justify="space-between" mt="lg">
                        <Checkbox label="자동 로그인" />
                        <Anchor component="button" size="sm">
                            비밀번호 찾기
                        </Anchor>
                    </Group>
                    <Button fullWidth mt="xl" onClick={handleLogin}>
                        로그인
                    </Button>
                </Stack>
            </Paper>

            <Text ta="center" mt="md" size="sm" c="dimmed">
                계정이 없으신가요?{' '}
                <Anchor href="#" fw={700} onClick={(e) => e.preventDefault()}>
                    회원가입
                </Anchor>
            </Text>
        </Container>
    );
}
