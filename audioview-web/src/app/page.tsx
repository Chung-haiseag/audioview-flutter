'use client';

import { Container, Stack, Box } from '@mantine/core';
import { HeroSection } from '@/components/HeroSection';
import { MovieCarousel } from '@/components/MovieCarousel';

const allMovies = [
  { id: 1, title: '히든페이스', posterUrl: 'https://image.tmdb.org/t/p/w500/1.jpg', year: 2024, genres: ['스릴러'], hasAD: true, hasCC: true },
  { id: 2, title: '범죄도시4', posterUrl: 'https://image.tmdb.org/t/p/w500/2.jpg', year: 2024, genres: ['액션'], hasAD: true, hasCC: true },
  { id: 3, title: '공동경비구역 JSA', posterUrl: 'https://image.tmdb.org/t/p/w500/3.jpg', year: 2000, genres: ['드라마'], hasAD: true, hasCC: true },
  { id: 4, title: '마지막 숙제', posterUrl: 'https://image.tmdb.org/t/p/w500/4.jpg', year: 2024, genres: ['드라마'], hasAD: true, hasCC: true },
  { id: 5, title: '서울의 봄', posterUrl: 'https://image.tmdb.org/t/p/w500/5.jpg', year: 2023, genres: ['드라마'], hasAD: true, hasCC: false },
  { id: 6, title: '파묘', posterUrl: 'https://image.tmdb.org/t/p/w500/6.jpg', year: 2024, genres: ['미스터리'], hasAD: false, hasCC: true },
  { id: 7, title: '기생충', posterUrl: 'https://image.tmdb.org/t/p/w500/7.jpg', year: 2019, genres: ['드라마'], hasAD: true, hasCC: true },
];

export default function Home() {
  const newMovies = allMovies.slice(0, 5);
  const popularMovies = [...allMovies].reverse();
  const actionMovies = allMovies.filter(m => m.genres.includes('액션') || m.genres.includes('스릴러'));

  return (
    <Box>
      <HeroSection />

      <Container size="xl" mt="-40px" style={{ position: 'relative', zIndex: 3 }}>
        {/* Negative margin to pull content up slightly over hero if desired, or just normal flow */}
        {/* Actually, let's keep it clean */}
      </Container>

      <Container fluid p={0}>
        <Stack gap="xl" pb="xl">
          <MovieCarousel title="새로 올라온 영화" movies={newMovies} />
          <MovieCarousel title="실시간 인기영화" movies={popularMovies} />
          <MovieCarousel title="심장이 쫄깃한 스릴러/액션" movies={actionMovies} />
        </Stack>
      </Container>
    </Box>
  );
}
