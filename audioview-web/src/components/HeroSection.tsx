import { Container, Title, Text, Button, Overlay, Box, Group } from '@mantine/core';
import { IconPlayerPlay, IconInfoCircle } from '@tabler/icons-react';

export function HeroSection() {
    return (
        <Box
            style={{
                position: 'relative',
                height: '70vh', // Mobile-first height
                maxHeight: '600px',
                backgroundImage: 'url(https://image.tmdb.org/t/p/original/tMefBSflR6PGQLv7WvFPpKLZkyk.jpg)', // Example image (Dune or similar)
                backgroundSize: 'cover',
                backgroundPosition: 'center',
                borderRadius: '0 0 16px 16px', // Rounded bottom corners for mobile feel
                overflow: 'hidden',
            }}
        >
            <Overlay
                gradient="linear-gradient(180deg, rgba(0, 0, 0, 0) 0%, rgba(26, 27, 30, 0.4) 50%, rgba(26, 27, 30, 1) 100%)"
                opacity={1}
                zIndex={1}
            />

            <Container size="md" style={{ position: 'relative', zIndex: 2, height: '100%' }}>
                <Box
                    style={{
                        position: 'absolute',
                        bottom: '60px', // Space for bottom nav or just padding
                        left: 0,
                        right: 0,
                        padding: '20px',
                    }}
                >
                    <Title c="white" order={1} style={{ fontSize: '3rem', fontWeight: 900, lineHeight: 1.1 }}>
                        범죄도시4
                    </Title>
                    <Text c="gray.3" mt="md" lineClamp={2} maw={600}>
                        괴물형사 ‘마석도’(마동석)가 다시 돌아왔다! 대규모 온라인 불법 도박 조직을 소탕하기 위해 대한민국 광수대와 사이버팀이 뭉쳤다. 나쁜 놈 잡는데 국경도 경찰도 없다!
                    </Text>

                    <Group mt="xl">
                        <Button
                            size="lg"
                            radius="xl"
                            leftSection={<IconPlayerPlay size={20} fill="currentColor" />}
                            color="white"
                            c="black"
                        >
                            재생
                        </Button>
                        <Button
                            size="lg"
                            radius="xl"
                            variant="default"
                            leftSection={<IconInfoCircle size={20} />}
                            bg="rgba(255, 255, 255, 0.2)"
                            style={{ border: 'none', color: 'white' }}
                        >
                            상세 정보
                        </Button>
                    </Group>
                </Box>
            </Container>
        </Box>
    );
}
