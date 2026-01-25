'use client';

import { Container, Title, Switch, Card, Text, Stack, Group, Divider, Select } from '@mantine/core';
import { useState } from 'react';

export default function SettingsPage() {
    const [adEnabled, setAdEnabled] = useState(true);
    const [ccEnabled, setCcEnabled] = useState(true);
    const [useMobileData, setUseMobileData] = useState(false);

    return (
        <Container size="sm" py="xl">
            <Title order={2} mb="xl">설정</Title>

            <Stack gap="lg">
                <Card withBorder radius="md">
                    <Text fw={600} mb="md" size="lg">접근성 설정</Text>
                    <Stack gap="md">
                        <Group justify="space-between">
                            <div>
                                <Text fw={500}>화면해설 (AD)</Text>
                                <Text size="sm" c="dimmed">시각장애인을 위한 화면 해설을 항상 켭니다</Text>
                            </div>
                            <Switch
                                size="lg"
                                checked={adEnabled}
                                onChange={(event) => setAdEnabled(event.currentTarget.checked)}
                                aria-label="화면해설 토글"
                            />
                        </Group>
                        <Divider />
                        <Group justify="space-between">
                            <div>
                                <Text fw={500}>자막 (CC)</Text>
                                <Text size="sm" c="dimmed">청각장애인을 위한 자막을 항상 표시합니다</Text>
                            </div>
                            <Switch
                                size="lg"
                                checked={ccEnabled}
                                onChange={(event) => setCcEnabled(event.currentTarget.checked)}
                                aria-label="자막 토글"
                            />
                        </Group>
                    </Stack>
                </Card>

                <Card withBorder radius="md">
                    <Text fw={600} mb="md" size="lg">재생 설정</Text>
                    <Stack gap="md">
                        <Group justify="space-between">
                            <div>
                                <Text fw={500}>모바일 데이터 사용</Text>
                                <Text size="sm" c="dimmed">Wi-Fi가 아닐 때도 영상을 재생합니다</Text>
                            </div>
                            <Switch
                                checked={useMobileData}
                                onChange={(event) => setUseMobileData(event.currentTarget.checked)}
                            />
                        </Group>
                        <Group justify="space-between">
                            <Text fw={500}>다운로드 화질</Text>
                            <Select
                                defaultValue="high"
                                data={[
                                    { value: 'high', label: '고화질 (1080p)' },
                                    { value: 'medium', label: '일반 (720p)' },
                                    { value: 'low', label: '데이터 절약 (480p)' },
                                ]}
                                w={150}
                            />
                        </Group>
                    </Stack>
                </Card>

                <Card withBorder radius="md">
                    <Text fw={600} mb="md" size="lg">고객센터</Text>
                    <Stack>
                        <Text size="sm" style={{ cursor: 'pointer' }}>공지사항</Text>
                        <Text size="sm" style={{ cursor: 'pointer' }}>자주 묻는 질문</Text>
                        <Text size="sm" style={{ cursor: 'pointer' }}>1:1 문의하기</Text>
                    </Stack>
                </Card>
            </Stack>
        </Container>
    );
}
