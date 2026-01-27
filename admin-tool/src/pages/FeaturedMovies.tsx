import React, { useEffect, useState } from 'react';
import {
    Box,
    Typography,
    Paper,
    Table,
    TableBody,
    TableCell,
    TableContainer,
    TableHead,
    TableRow,
    IconButton,
    TextField,
    CircularProgress,
    Chip,
    InputAdornment,
} from '@mui/material';
import {
    Delete as DeleteIcon,
    Search as SearchIcon,
    Link as LinkIcon,
} from '@mui/icons-material';
import { getFeaturedLists, getFeaturedMovies, removeMovieFromFeatured } from '../services/featuredService';
import { FeaturedMovie, Movie } from '../types';
import { format } from 'date-fns';

interface FeaturedMovieWithInfo extends FeaturedMovie {
    listName?: string;
    movieTitle?: string;
    movie?: Movie;
}

const FeaturedMovies: React.FC = () => {
    const [loading, setLoading] = useState(true);
    const [allLinks, setAllLinks] = useState<FeaturedMovieWithInfo[]>([]);
    const [searchTerm, setSearchTerm] = useState('');

    useEffect(() => {
        fetchLinks();
    }, []);

    const fetchLinks = async () => {
        try {
            setLoading(true);
            const lists = await getFeaturedLists();

            // 모든 목록의 영화 연결 정보를 병합
            const allPromises = lists.map(async (list) => {
                const movies = await getFeaturedMovies(list.listId);
                return movies.map(m => ({
                    ...m,
                    listName: list.listName
                }));
            });

            const results = await Promise.all(allPromises);
            const flatLinks = results.flat();

            setAllLinks(flatLinks);
        } catch (error) {
            console.error('연결 데이터 조회 오류:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleDeleteLink = async (featuredId: string) => {
        if (window.confirm('이 영화와 특별 목록의 연결을 해제하시겠습니까?')) {
            try {
                await removeMovieFromFeatured(featuredId);
                fetchLinks();
            } catch (error) {
                console.error('연결 삭제 오류:', error);
                alert('삭제 중 오류가 발생했습니다.');
            }
        }
    };

    const filteredLinks = allLinks.filter(link =>
        link.listName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        link.movie?.title?.toLowerCase().includes(searchTerm.toLowerCase())
    );

    return (
        <Box>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
                <Typography variant="h4" fontWeight="bold">특별 목록-영화 연결 관리</Typography>
                <Box sx={{ display: 'flex', gap: 1 }}>
                    <LinkIcon color="primary" sx={{ fontSize: 40 }} />
                </Box>
            </Box>

            <Paper sx={{ p: 2, mb: 3 }}>
                <TextField
                    fullWidth
                    placeholder="목록 이름 또는 영화 제목으로 검색..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    InputProps={{
                        startAdornment: (
                            <InputAdornment position="start">
                                <SearchIcon />
                            </InputAdornment>
                        ),
                    }}
                />
            </Paper>

            {loading ? (
                <Box sx={{ display: 'flex', justifyContent: 'center', p: 4 }}><CircularProgress /></Box>
            ) : (
                <TableContainer component={Paper}>
                    <Table>
                        <TableHead>
                            <TableRow>
                                <TableCell>목록 이름</TableCell>
                                <TableCell>영화 제목</TableCell>
                                <TableCell>정렬 순서</TableCell>
                                <TableCell>등록일</TableCell>
                                <TableCell align="center">액션</TableCell>
                            </TableRow>
                        </TableHead>
                        <TableBody>
                            {filteredLinks.length === 0 ? (
                                <TableRow><TableCell colSpan={5} align="center">연결 데이터가 없습니다.</TableCell></TableRow>
                            ) : (
                                filteredLinks.map((link) => (
                                    <TableRow key={link.featuredId} hover>
                                        <TableCell>
                                            <Chip
                                                label={link.listName}
                                                size="small"
                                                color="primary"
                                                variant="outlined"
                                            />
                                        </TableCell>
                                        <TableCell>
                                            <Typography variant="body2" fontWeight="bold">
                                                {link.movie?.title || '알 수 없는 영화'}
                                            </Typography>
                                        </TableCell>
                                        <TableCell>{link.displayOrder}</TableCell>
                                        <TableCell>
                                            {link.featuredDate ? format(link.featuredDate, 'yyyy-MM-dd HH:mm') : '-'}
                                        </TableCell>
                                        <TableCell align="center">
                                            <IconButton
                                                size="small"
                                                color="error"
                                                onClick={() => handleDeleteLink(link.featuredId)}
                                                title="연결 해제"
                                            >
                                                <DeleteIcon fontSize="small" />
                                            </IconButton>
                                        </TableCell>
                                    </TableRow>
                                ))
                            )}
                        </TableBody>
                    </Table>
                </TableContainer>
            )}
        </Box>
    );
};

export default FeaturedMovies;
