'use client';

import { AppShell, Burger, Group, Text, ScrollArea, NavLink, TextInput, SimpleGrid, Card, Image, Badge, Title, Container, Button, Stack, ThemeIcon, ActionIcon, rem } from '@mantine/core';
import { useDisclosure } from '@mantine/hooks';
import { IconHome, IconMovie, IconSettings, IconUser, IconSearch, IconPlayerPlay, IconHeart } from '@tabler/icons-react';
import { useState } from 'react';

// Mock Data from Flutter project
const movies = [
  {
    id: '1',
    title: '거룩한 밤: 데몬 헌터스',
    year: 2025,
    country: '대한민국',
    duration: 92,
    genres: ['영화', '액션', '판타지'],
    posterUrl: 'https://images.unsplash.com/photo-1626814026160-2237a95fc5a0?q=80&w=300&h=450&auto=format&fit=crop',
    hasAD: true,
    hasCC: true,
  },
  {
    id: '2',
    title: '검은 수녀들',
    year: 2025,
    country: '대한민국',
    duration: 115,
    genres: ['영화', '공포', '미스터리'],
    posterUrl: 'https://images.unsplash.com/photo-1509248961158-e54f6934749c?q=80&w=300&h=450&auto=format&fit=crop',
    hasAD: true,
    hasCC: true,
  },
  {
    id: '3',
    title: '큘레큘레',
    year: 2025,
    country: '대한민국',
    duration: 108,
    genres: ['영화', '드라마', '로맨스'],
    posterUrl: 'https://images.unsplash.com/photo-1536440136628-849c177e76a1?q=80&w=300&h=450&auto=format&fit=crop',
    hasAD: true,
    hasCC: true,
  },
  {
    id: '6',
    title: '인사이드 아웃 2',
    year: 2024,
    country: '미국',
    duration: 96,
    genres: ['영화', '애니', '가족', '해외'],
    posterUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=300&h=450&auto=format&fit=crop',
    hasAD: true,
    hasCC: true,
  },
  {
    id: 's2',
    title: '뉴욕의 밤: 수사대',
    year: 2023,
    country: '미국',
    duration: 45,
    genres: ['드라마', '범죄', '해외'],
    posterUrl: 'https://images.unsplash.com/photo-1485846234645-a62644f84728?q=80&w=300&h=450&auto=format&fit=crop',
    hasAD: true,
    hasCC: true,
  },
  {
    id: 'a1',
    title: '푸른 숲의 요정',
    year: 2024,
    country: '일본',
    duration: 25,
    genres: ['애니', '판타지'],
    posterUrl: 'https://images.unsplash.com/photo-1578632292335-df3abbb0d586?q=80&w=300&h=450&auto=format&fit=crop',
    hasAD: true,
    hasCC: true,
  },
  {
    id: 'a2',
    title: '사이버 펑크 2099',
    year: 2025,
    country: '미국',
    duration: 30,
    genres: ['애니', 'SF', '해외'],
    posterUrl: 'https://images.unsplash.com/photo-1542751371-adc38448a05e?q=80&w=300&h=450&auto=format&fit=crop',
    hasAD: true,
    hasCC: true,
  },
  {
    id: 'e1',
    title: '요리 대첩: 파이널',
    year: 2025,
    country: '한국',
    duration: 90,
    genres: ['예능', '서바이벌'],
    posterUrl: 'https://images.unsplash.com/photo-1556910103-1c02745aae4d?q=80&w=300&h=450&auto=format&fit=crop',
    hasAD: true,
    hasCC: true,
  },
];

export default function Home() {
  const [opened, { toggle }] = useDisclosure();
  const [active, setActive] = useState(0);

  const navItems = [
    { icon: IconHome, label: '홈', href: '#' },
    { icon: IconMovie, label: '영화', href: '#' },
    { icon: IconUser, label: 'MY', href: '#' },
    { icon: IconSettings, label: '설정', href: '#' },
  ];

  return (
    <AppShell
      header={{ height: 70 }}
      navbar={{
        width: 250,
        breakpoint: 'sm',
        collapsed: { mobile: !opened },
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
            <ActionIcon variant="light" size="lg" radius="xl">
              <IconUser size={20} />
            </ActionIcon>
          </Group>
        </Group>
      </AppShell.Header>

      <AppShell.Navbar p="md">
        <Stack gap="xs">
          {navItems.map((item, index) => (
            <NavLink
              key={item.label}
              active={index === active}
              label={item.label}
              leftSection={<item.icon size={20} stroke={1.5} />}
              onClick={() => setActive(index)}
              variant="light"
              color="violet"
              style={{ borderRadius: 8 }}
            />
          ))}
        </Stack>
      </AppShell.Navbar>

      <AppShell.Main>
        <Container fluid>
          <Stack gap="xl">
            {/* Hero Section */}
            <Card
              radius="lg"
              p="xl"
              h={400}
              style={{
                backgroundImage: `linear-gradient(rgba(0,0,0,0.5), rgba(0,0,0,0.8)), url(${movies[0].posterUrl})`,
                backgroundSize: 'cover',
                backgroundPosition: 'center',
                display: 'flex',
                flexDirection: 'column',
                justifyContent: 'flex-end',
              }}
            >
              <Stack gap="md" maw={600}>
                <Badge size="lg" color="red">NEW</Badge>
                <Title order={1} c="white" size={48}>{movies[0].title}</Title>
                <Text c="gray.3" size="lg" lineClamp={2}>
                  악에 맞서 싸우는 신성한 힘! 데몬 헌터들의 숨막히는 액션이 시작된다.
                  {movies[0].year} • {movies[0].genres.join(', ')} • {movies[0].duration}분
                </Text>
                <Group>
                  <Button size="lg" leftSection={<IconPlayerPlay size={20} />} color="red">
                    재생하기
                  </Button>
                  <Button size="lg" variant="light" leftSection={<IconHeart size={20} />}>
                    찜하기
                  </Button>
                </Group>
              </Stack>
            </Card>

            {/* Movie Grid */}
            <Stack>
              <Title order={2}>최신 업데이트</Title>
              <SimpleGrid cols={{ base: 2, sm: 3, md: 4, lg: 5 }} spacing="lg">
                {movies.map((movie) => (
                  <Card key={movie.id} shadow="sm" padding="none" radius="md" withBorder={false} style={{ cursor: 'pointer', backgroundColor: 'transparent' }}>
                    <Card.Section>
                      <Image
                        src={movie.posterUrl}
                        h={320}
                        alt={movie.title}
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
                ))}
              </SimpleGrid>
            </Stack>
          </Stack>
        </Container>
      </AppShell.Main>
    </AppShell>
  );
}
