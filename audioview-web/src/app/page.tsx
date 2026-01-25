'use client';

import { Text, SimpleGrid, Card, Badge, Title, Container, Button, Stack, Group, Chip } from '@mantine/core';
import { IconPlayerPlay, IconHeart } from '@tabler/icons-react';
import { useState } from 'react';
import { MovieCard } from '../components/MovieCard';

// Mock Data
const allMovies = [
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

const categoryChips = ['전체', '영화', '드라마', '예능', '애니', '시사교양'];

export default function Home() {
  const [selectedCategory, setSelectedCategory] = useState('전체');

  const filteredMovies = selectedCategory === '전체'
    ? allMovies
    : allMovies.filter(m => m.genres.includes(selectedCategory));

  return (
    <Container fluid>
      <Stack gap="xl">
        {/* Hero Section */}
        <Card
          radius="lg"
          p="xl"
          h={400}
          style={{
            backgroundImage: `linear-gradient(rgba(0,0,0,0.5), rgba(0,0,0,0.8)), url(${allMovies[0].posterUrl})`,
            backgroundSize: 'cover',
            backgroundPosition: 'center',
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'flex-end',
          }}
        >
          <Stack gap="md" maw={600}>
            <Badge size="lg" color="red">NEW</Badge>
            <Title order={1} c="white" size={48}>{allMovies[0].title}</Title>
            <Text c="gray.3" size="lg" lineClamp={2}>
              악에 맞서 싸우는 신성한 힘! 데몬 헌터들의 숨막히는 액션이 시작된다.
              {allMovies[0].year} • {allMovies[0].genres.join(', ')} • {allMovies[0].duration}분
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

        {/* Filter Chips */}
        <Group>
          {categoryChips.map((chip) => (
            <Chip
              key={chip}
              checked={selectedCategory === chip}
              onChange={() => setSelectedCategory(chip)}
              color="violet"
              variant="light"
            >
              {chip}
            </Chip>
          ))}
        </Group>

        {/* Movie Grid */}
        <Stack>
          <Title order={2}>
            {selectedCategory === '전체' ? '최신 업데이트' : `${selectedCategory} 콘텐츠`}
          </Title>
          {filteredMovies.length > 0 ? (
            <SimpleGrid cols={{ base: 2, sm: 3, md: 4, lg: 5 }} spacing="lg">
              {filteredMovies.map((movie) => (
                <MovieCard key={movie.id} movie={movie} />
              ))}
            </SimpleGrid>
          ) : (
            <Text c="dimmed" py="xl">해당 카테고리의 콘텐츠가 없습니다.</Text>
          )}
        </Stack>
      </Stack>
    </Container>
  );
}
