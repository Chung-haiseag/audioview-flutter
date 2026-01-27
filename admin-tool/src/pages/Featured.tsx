import React, { useEffect, useState } from 'react';
import {
    Box,
    Typography,
    Button,
    Paper,
    IconButton,
    TextField,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions,
    CircularProgress,
    Switch,
    FormControlLabel,
    List,
    ListItem,
    ListItemText,
    ListItemSecondaryAction,
    Divider,
    Grid,
} from '@mui/material';
import {
    Add as AddIcon,
    Edit as EditIcon,
    Delete as DeleteIcon,
    Movie as MovieIcon,
} from '@mui/icons-material';
import {
    getFeaturedLists,
    addFeaturedList,
    updateFeaturedList,
    deleteFeaturedList,
    getFeaturedMovies,
    addMovieToFeatured,
    removeMovieFromFeatured,
} from '../services/featuredService';
import { getMovies } from '../services/movieService';
import { FeaturedList, FeaturedMovie, Movie } from '../types';

const Featured: React.FC = () => {
    const [lists, setLists] = useState<FeaturedList[]>([]);
    const [loading, setLoading] = useState(true);
    const [movies, setMovies] = useState<Movie[]>([]);

    // 목록 관리 다이얼로그
    const [openListDialog, setOpenListDialog] = useState(false);
    const [editingList, setEditingList] = useState<FeaturedList | null>(null);
    const [listFormData, setListFormData] = useState<Partial<FeaturedList>>({
        listName: '',
        listDescription: '',
        maxItems: 10,
        isActive: true,
        displayOrder: 0,
    });

    // 영화 관리 다이얼로그
    const [openMovieDialog, setOpenMovieDialog] = useState(false);
    const [selectedList, setSelectedList] = useState<FeaturedList | null>(null);
    const [featuredMovies, setFeaturedMovies] = useState<(FeaturedMovie & { movie?: Movie })[]>([]);
    const [movieLoading, setMovieLoading] = useState(false);

    useEffect(() => {
        fetchData();
    }, []);

    const fetchData = async () => {
        try {
            setLoading(true);
            const [listData, movieData] = await Promise.all([getFeaturedLists(), getMovies()]);
            setLists(listData);
            setMovies(movieData);
        } catch (error) {
            console.error('데이터 조회 오류:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleOpenAddList = () => {
        setEditingList(null);
        setListFormData({ listName: '', listDescription: '', maxItems: 10, isActive: true, displayOrder: lists.length });
        setOpenListDialog(true);
    };

    const handleOpenEditList = (list: FeaturedList) => {
        setEditingList(list);
        setListFormData({ ...list });
        setOpenListDialog(true);
    };

    const handleCloseListDialog = () => setOpenListDialog(false);

    const handleSubmitList = async () => {
        try {
            if (editingList) {
                await updateFeaturedList(editingList.listId, listFormData);
            } else {
                await addFeaturedList(listFormData as Omit<FeaturedList, 'listId' | 'createdAt'>);
            }
            handleCloseListDialog();
            fetchData();
        } catch (error) {
            console.error('목록 저장 오류:', error);
            alert('저장 중 오류가 발생했습니다.');
        }
    };

    const handleDeleteList = async (id: string) => {
        if (window.confirm('이 특별 목록을 삭제하시겠습니까? 관련 영화 연결 정보도 모두 삭제됩니다.')) {
            try {
                await deleteFeaturedList(id);
                fetchData();
            } catch (error) {
                console.error('목록 삭제 오류:', error);
            }
        }
    };

    // 영화 관리
    const handleOpenManageMovies = async (list: FeaturedList) => {
        setSelectedList(list);
        setOpenMovieDialog(true);
        loadFeaturedMovies(list.listId);
    };

    const loadFeaturedMovies = async (listId: string) => {
        try {
            setMovieLoading(true);
            const data = await getFeaturedMovies(listId);
            setFeaturedMovies(data);
        } catch (error) {
            console.error('목록 내 영화 조회 오류:', error);
        } finally {
            setMovieLoading(false);
        }
    };

    const handleAddMovie = async (movieId: string) => {
        if (!selectedList) return;
        try {
            await addMovieToFeatured(selectedList.listId, movieId, featuredMovies.length);
            loadFeaturedMovies(selectedList.listId);
        } catch (error: any) {
            alert(error.message);
        }
    };

    const handleRemoveMovie = async (featuredId: string) => {
        try {
            await removeMovieFromFeatured(featuredId);
            if (selectedList) loadFeaturedMovies(selectedList.listId);
        } catch (error) {
            console.error('영화 제거 오류:', error);
        }
    };

    return (
        <Box>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
                <Typography variant="h4" fontWeight="bold">특별 목록 관리</Typography>
                <Button variant="contained" startIcon={<AddIcon />} onClick={handleOpenAddList}>목록 추가</Button>
            </Box>

            {loading ? (
                <Box sx={{ display: 'flex', justifyContent: 'center', p: 4 }}><CircularProgress /></Box>
            ) : (
                <Grid container spacing={3}>
                    {lists.map((list) => (
                        <Grid size={{ xs: 12, md: 6 }} key={list.listId}>
                            <Paper sx={{ p: 2 }}>
                                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                                    <Box>
                                        <Typography variant="h6" fontWeight="bold">
                                            {list.listName}
                                            {!list.isActive && <Typography component="span" color="error" variant="caption" sx={{ ml: 1 }}>(비활성)</Typography>}
                                        </Typography>
                                        <Typography variant="body2" color="text.secondary">{list.listDescription || '설명 없음'}</Typography>
                                        <Typography variant="caption" sx={{ display: 'block', mt: 1 }}>최대 항목: {list.maxItems}개</Typography>
                                    </Box>
                                    <Box>
                                        <IconButton size="small" color="primary" onClick={() => handleOpenManageMovies(list)} title="영화 관리"><MovieIcon /></IconButton>
                                        <IconButton size="small" onClick={() => handleOpenEditList(list)}><EditIcon /></IconButton>
                                        <IconButton size="small" color="error" onClick={() => handleDeleteList(list.listId)}><DeleteIcon /></IconButton>
                                    </Box>
                                </Box>
                            </Paper>
                        </Grid>
                    ))}
                </Grid>
            )}

            {/* 목록 추가/수정 다이얼로그 */}
            <Dialog open={openListDialog} onClose={handleCloseListDialog} fullWidth maxWidth="xs">
                <DialogTitle>{editingList ? '특별 목록 수정' : '새 특별 목록 등록'}</DialogTitle>
                <DialogContent dividers>
                    <Grid container spacing={2} sx={{ mt: 0.5 }}>
                        <Grid size={12}>
                            <TextField fullWidth label="목록 이름*" value={listFormData.listName} onChange={(e) => setListFormData(p => ({ ...p, listName: e.target.value }))} />
                        </Grid>
                        <Grid size={12}>
                            <TextField fullWidth label="설명" multiline rows={2} value={listFormData.listDescription} onChange={(e) => setListFormData(p => ({ ...p, listDescription: e.target.value }))} />
                        </Grid>
                        <Grid size={6}>
                            <TextField fullWidth type="number" label="최대 항목 수" value={listFormData.maxItems} onChange={(e) => setListFormData(p => ({ ...p, maxItems: parseInt(e.target.value) }))} />
                        </Grid>
                        <Grid size={6}>
                            <TextField fullWidth type="number" label="표시 순서" value={listFormData.displayOrder} onChange={(e) => setListFormData(p => ({ ...p, displayOrder: parseInt(e.target.value) }))} />
                        </Grid>
                        <Grid size={12}>
                            <FormControlLabel control={<Switch checked={listFormData.isActive} onChange={(e) => setListFormData(p => ({ ...p, isActive: e.target.checked }))} />} label="활성화 여부" />
                        </Grid>
                    </Grid>
                </DialogContent>
                <DialogActions>
                    <Button onClick={handleCloseListDialog}>취소</Button>
                    <Button onClick={handleSubmitList} variant="contained">저장</Button>
                </DialogActions>
            </Dialog>

            {/* 영화 관리 다이얼로그 */}
            <Dialog open={openMovieDialog} onClose={() => setOpenMovieDialog(false)} fullWidth maxWidth="md">
                <DialogTitle>
                    <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                        <Typography variant="h6">[{selectedList?.listName}] 영화 관리</Typography>
                        <Typography variant="body2" color="text.secondary">포함된 영화: {featuredMovies.length} / {selectedList?.maxItems}</Typography>
                    </Box>
                </DialogTitle>
                <DialogContent dividers>
                    <Grid container spacing={2}>
                        <Grid size={{ xs: 12, md: 6 }}>
                            <Typography variant="subtitle2" sx={{ mb: 1, fontWeight: 'bold' }}>현재 목록</Typography>
                            <Paper variant="outlined" sx={{ height: 400, overflow: 'auto' }}>
                                {movieLoading ? (
                                    <Box sx={{ display: 'flex', justifyContent: 'center', p: 4 }}><CircularProgress size={24} /></Box>
                                ) : (
                                    <List dense>
                                        {featuredMovies.map((fm, index) => (
                                            <React.Fragment key={fm.featuredId}>
                                                <ListItem>
                                                    <ListItemText
                                                        primary={fm.movie?.title || '정보 없음'}
                                                        secondary={`순서: ${fm.displayOrder}`}
                                                    />
                                                    <ListItemSecondaryAction>
                                                        <IconButton edge="end" size="small" color="error" onClick={() => handleRemoveMovie(fm.featuredId)}>
                                                            <DeleteIcon fontSize="small" />
                                                        </IconButton>
                                                    </ListItemSecondaryAction>
                                                </ListItem>
                                                {index < featuredMovies.length - 1 && <Divider />}
                                            </React.Fragment>
                                        ))}
                                        {featuredMovies.length === 0 && <Box sx={{ p: 2, textAlign: 'center' }}><Typography variant="body2" color="text.secondary">목록이 비어 있습니다.</Typography></Box>}
                                    </List>
                                )}
                            </Paper>
                        </Grid>
                        <Grid size={{ xs: 12, md: 6 }}>
                            <Typography variant="subtitle2" sx={{ mb: 1, fontWeight: 'bold' }}>영화 추가</Typography>
                            <Paper variant="outlined" sx={{ height: 400, overflow: 'auto' }}>
                                <List dense>
                                    {movies.filter(m => !featuredMovies.some(fm => fm.movieId === m.movieId)).map((movie) => (
                                        <React.Fragment key={movie.movieId}>
                                            <ListItem>
                                                <ListItemText primary={movie.title} secondary={movie.directorName} />
                                                <ListItemSecondaryAction>
                                                    <IconButton edge="end" size="small" color="primary" onClick={() => handleAddMovie(movie.movieId)}>
                                                        <AddIcon fontSize="small" />
                                                    </IconButton>
                                                </ListItemSecondaryAction>
                                            </ListItem>
                                            <Divider />
                                        </React.Fragment>
                                    ))}
                                </List>
                            </Paper>
                        </Grid>
                    </Grid>
                </DialogContent>
                <DialogActions>
                    <Button onClick={() => setOpenMovieDialog(false)}>닫기</Button>
                </DialogActions>
            </Dialog>
        </Box>
    );
};

export default Featured;
