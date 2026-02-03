import React, { useEffect, useState } from 'react';
import {
    Box,
    Typography,
    Button,
    Paper,
    Table,
    TableBody,
    TableCell,
    TableContainer,
    TableHead,
    TableRow,
    IconButton,
    TextField,
    Dialog,
    DialogTitle,
    DialogContent,
    DialogActions,
    Checkbox,
    FormControlLabel,
    InputAdornment,
    CircularProgress,
    MenuItem,
    Select,
    FormControl,
    InputLabel,
    Chip,
    Grid,
} from '@mui/material';
import {
    Add as AddIcon,
    Edit as EditIcon,
    Delete as DeleteIcon,
    Search as SearchIcon,
} from '@mui/icons-material';
import { getMovies, addMovie, updateMovie, deleteMovie } from '../services/movieService';
import { getGenres, Genre } from '../services/genreService';
import { uploadFile } from '../services/uploadService';
import { Movie } from '../types';

const Movies: React.FC = () => {
    const [movies, setMovies] = useState<Movie[]>([]);
    const [genres, setGenres] = useState<Genre[]>([]);
    const [loading, setLoading] = useState(true);
    const [uploading, setUploading] = useState(false);
    const [searchTerm, setSearchTerm] = useState('');

    // 다이얼로그 상태
    const [openDialog, setOpenDialog] = useState(false);
    const [editingMovie, setEditingMovie] = useState<Movie | null>(null);
    const [formData, setFormData] = useState<Partial<Movie>>({
        title: '',
        directorName: '',
        runningTime: 120,
        synopsis: '',
        posterUrl: '',
        rating: 'ALL',
        hasAudioCommentary: false,
        hasClosedCaption: false,
        audioCommentaryFile: '',
        closedCaptionFile: '',
        audioIntroUrl: '',
        genreId: '',
        productionCountry: '',
        searchKeywords: [],
    });

    useEffect(() => {
        fetchData();
    }, []);

    const fetchData = async () => {
        try {
            setLoading(true);
            const [movieData, genreData] = await Promise.all([
                getMovies(),
                getGenres(),
            ]);
            setMovies(movieData);
            setGenres(genreData);
        } catch (error) {
            console.error('데이터 조회 오류:', error);
        } finally {
            setLoading(false);
        }
    };

    const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        if (file.size > 5 * 1024 * 1024) {
            alert('파일 크기가 너무 큽니다. 5MB 이하의 이미지만 업로드 가능합니다.');
            return;
        }

        try {
            setUploading(true);
            const url = await uploadFile(file, 'posters');
            setFormData(prev => ({ ...prev, posterUrl: url }));
            alert('이미지가 성공적으로 업로드되었습니다.');
        } catch (error: any) {
            console.error('이미지 업로드 실패:', error);
            alert('이미지 업로드 중 오류가 발생했습니다.');
        } finally {
            setUploading(false);
            e.target.value = '';
        }
    };

    const handleAudioUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (!file) return;

        if (file.size > 10 * 1024 * 1024) {
            alert('파일 크기가 너무 큽니다. 10MB 이하의 MP3 파일만 업로드 가능합니다.');
            return;
        }

        try {
            setUploading(true);
            const url = await uploadFile(file, 'audio-intros');
            setFormData(prev => ({ ...prev, audioIntroUrl: url }));
            alert('음성 파일이 성공적으로 업로드되었습니다.');
        } catch (error: any) {
            console.error('음성 파일 업로드 실패:', error);
            alert('음성 파일 업로드 중 오류가 발생했습니다.');
        } finally {
            setUploading(false);
            e.target.value = '';
        }
    };

    const handleOpenAdd = () => {
        setEditingMovie(null);
        setFormData({
            title: '',
            directorName: '',
            runningTime: 120,
            synopsis: '',
            posterUrl: '',
            rating: 'ALL',
            hasAudioCommentary: false,
            hasClosedCaption: false,
            audioCommentaryFile: '',
            closedCaptionFile: '',
            audioIntroUrl: '',
            genreId: '',
            productionCountry: '',
            searchKeywords: [],
        });
        setOpenDialog(true);
    };

    const handleOpenEdit = (movie: Movie) => {
        setEditingMovie(movie);
        setFormData({ ...movie });
        setOpenDialog(true);
    };

    const handleCloseDialog = () => setOpenDialog(false);

    const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const { name, value, checked, type } = e.target;
        setFormData((prev) => ({
            ...prev,
            [name]: type === 'checkbox' ? checked : (name === 'releaseDate' ? new Date(value) : value),
        }));
    };

    const handleSubmit = async () => {
        try {
            const finalData = {
                ...formData,
                searchKeywords: typeof formData.searchKeywords === 'string'
                    ? (formData.searchKeywords as string).split(',').map(s => s.trim()).filter(s => s !== '')
                    : formData.searchKeywords
            };

            if (editingMovie) {
                await updateMovie(editingMovie.movieId, finalData);
            } else {
                await addMovie(finalData as Omit<Movie, 'movieId' | 'createdAt' | 'updatedAt'>);
            }
            handleCloseDialog();
            fetchData();
        } catch (error) {
            console.error('영화 저장 오류:', error);
            alert('저장 중 오류가 발생했습니다.');
        }
    };

    const handleDelete = async (movieId: string) => {
        if (window.confirm('정말로 이 영화 정보를 삭제하시겠습니까?')) {
            try {
                await deleteMovie(movieId);
                fetchData();
            } catch (error) {
                console.error('영화 삭제 오류:', error);
                alert('삭제 중 오류가 발생했습니다.');
            }
        }
    };

    const getGenreName = (id?: string) => {
        if (!id) return '-';
        return genres.find(g => g.genreId === id)?.genreName || '-';
    };

    const filteredMovies = movies.filter(
        (movie) =>
            movie.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
            movie.directorName?.toLowerCase().includes(searchTerm.toLowerCase())
    );

    return (
        <Box>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
                <Typography variant="h4" fontWeight="bold">영화 관리</Typography>
                <Button variant="contained" startIcon={<AddIcon />} onClick={handleOpenAdd}>영화 추가</Button>
            </Box>

            <Paper sx={{ p: 2, mb: 2 }}>
                <TextField
                    fullWidth
                    placeholder="영화 제목 또는 감독 검색..."
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
                                <TableCell>포스터</TableCell>
                                <TableCell>제목/정보</TableCell>
                                <TableCell>감독/제작사</TableCell>
                                <TableCell>등급/러닝타임</TableCell>
                                <TableCell>베리어프리</TableCell>
                                <TableCell>태그</TableCell>
                                <TableCell align="center">액션</TableCell>
                            </TableRow>
                        </TableHead>
                        <TableBody>
                            {filteredMovies.length === 0 ? (
                                <TableRow><TableCell colSpan={7} align="center">데이터가 없습니다</TableCell></TableRow>
                            ) : (
                                filteredMovies.map((movie) => (
                                    <TableRow key={movie.movieId} hover>
                                        <TableCell>
                                            <Box
                                                component="img"
                                                src={movie.posterUrl || 'https://via.placeholder.com/50x75'}
                                                sx={{ width: 50, height: 75, objectFit: 'cover', borderRadius: 1 }}
                                            />
                                        </TableCell>
                                        <TableCell>
                                            <Typography variant="body2" fontWeight="bold">{movie.title}</Typography>
                                            <Typography variant="caption" display="block" color="text.secondary" sx={{ fontFamily: 'monospace' }}>ID: {movie.movieId}</Typography>
                                            <Typography variant="caption" color="primary">{getGenreName(movie.genreId)}</Typography>
                                        </TableCell>
                                        <TableCell>
                                            <Typography variant="body2">{movie.directorName || '-'}</Typography>
                                            {movie.productionCountry && <Typography variant="caption" color="text.secondary">({movie.productionCountry})</Typography>}
                                        </TableCell>
                                        <TableCell>
                                            <Chip label={movie.rating} size="small" variant="outlined" sx={{ mr: 0.5 }} />
                                            <Typography variant="caption">{movie.runningTime}분</Typography>
                                        </TableCell>
                                        <TableCell>
                                            {movie.hasAudioCommentary && <Chip label="해설" size="small" color="primary" sx={{ mr: 0.5 }} />}
                                            {movie.hasClosedCaption && <Chip label="자막" size="small" color="secondary" />}
                                        </TableCell>
                                        <TableCell>
                                            {/* Tags like isLatest/isPopular removed as they are now admin-managed via Special Lists */}
                                        </TableCell>
                                        <TableCell align="center">
                                            <IconButton size="small" color="primary" onClick={() => handleOpenEdit(movie)}><EditIcon /></IconButton>
                                            <IconButton size="small" color="error" onClick={() => handleDelete(movie.movieId)}><DeleteIcon /></IconButton>
                                        </TableCell>
                                    </TableRow>
                                ))
                            )}
                        </TableBody>
                    </Table>
                </TableContainer>
            )}

            <Dialog open={openDialog} onClose={handleCloseDialog} maxWidth="md" fullWidth>
                <DialogTitle>{editingMovie ? '영화 정보 수정' : '새 영화 등록'}</DialogTitle>
                <DialogContent dividers>
                    <Grid container spacing={2} sx={{ mt: 0.5 }}>
                        {editingMovie && (
                            <Grid size={{ xs: 12 }}>
                                <TextField
                                    fullWidth
                                    label="ID"
                                    value={editingMovie.movieId}
                                    disabled
                                    variant="outlined"
                                    size="small"
                                    helperText="영화 고유 식별코드입니다."
                                />
                            </Grid>
                        )}
                        <Grid size={{ xs: 12 }}>
                            <TextField fullWidth label="영화 제목*" name="title" value={formData.title} onChange={handleInputChange} required />
                        </Grid>
                        <Grid size={{ xs: 12, sm: 6 }}>
                            <FormControl fullWidth>
                                <InputLabel>장르</InputLabel>
                                <Select
                                    name="genreId"
                                    value={formData.genreId || ''}
                                    label="장르"
                                    onChange={(e) => setFormData(p => ({ ...p, genreId: e.target.value }))}
                                >
                                    <MenuItem value="">장르 미선택</MenuItem>
                                    {genres.map(g => <MenuItem key={g.genreId} value={g.genreId}>{g.genreName}</MenuItem>)}
                                </Select>
                            </FormControl>
                        </Grid>
                        <Grid size={{ xs: 12, sm: 8 }}>
                            <TextField fullWidth label="제작국가" name="productionCountry" value={formData.productionCountry || ''} onChange={handleInputChange} />
                        </Grid>
                        <Grid size={{ xs: 12, sm: 4 }}>
                            <TextField fullWidth label="감독" name="directorName" value={formData.directorName} onChange={handleInputChange} />
                        </Grid>
                        <Grid size={{ xs: 12, sm: 6 }}>
                            <TextField fullWidth label="러닝타임" name="runningTime" type="number" value={formData.runningTime} onChange={handleInputChange} />
                        </Grid>
                        <Grid size={{ xs: 12, sm: 6 }}>
                            <TextField
                                fullWidth
                                label="개봉일*"
                                name="releaseDate"
                                type="date"
                                value={formData.releaseDate instanceof Date && !isNaN(formData.releaseDate.getTime()) ? formData.releaseDate.toISOString().split('T')[0] : ''}
                                onChange={handleInputChange}
                                InputLabelProps={{ shrink: true }}
                                required
                            />
                        </Grid>
                        <Grid size={{ xs: 12, sm: 4 }}>
                            <FormControl fullWidth>
                                <InputLabel>등급</InputLabel>
                                <Select
                                    name="rating"
                                    value={formData.rating || 'ALL'}
                                    label="등급"
                                    onChange={(e) => setFormData(p => ({ ...p, rating: e.target.value }))}
                                >
                                    <MenuItem value="ALL">전체</MenuItem>
                                    <MenuItem value="12">12세</MenuItem>
                                    <MenuItem value="15">15세</MenuItem>
                                    <MenuItem value="19">청불</MenuItem>
                                </Select>
                            </FormControl>
                        </Grid>
                        <Grid size={12}>
                            <TextField
                                fullWidth
                                label="줄거리"
                                name="synopsis"
                                value={formData.synopsis}
                                onChange={handleInputChange}
                                multiline
                                rows={4}
                            />
                        </Grid>
                        <Grid size={12}>
                            <TextField
                                fullWidth
                                label="검색 키워드"
                                name="searchKeywords"
                                value={Array.isArray(formData.searchKeywords) ? formData.searchKeywords.join(', ') : formData.searchKeywords || ''}
                                onChange={handleInputChange}
                                placeholder="키워드를 쉼표(,)로 구분하여 입력하세요 (예: 액션, 마동석, 범죄)"
                                helperText="여기 입력된 키워드는 앱의 검색 엔진에서 최우선으로 검색됩니다."
                            />
                        </Grid>
                        <Grid size={12}>
                            {/* Home Screen visibility is now managed in "Special List Management" */}
                        </Grid>
                        <Grid size={12}>
                            <Box sx={{ display: 'flex', gap: 2, alignItems: 'center' }}>
                                <TextField
                                    fullWidth
                                    label="포스터 URL"
                                    name="posterUrl"
                                    value={formData.posterUrl}
                                    onChange={handleInputChange}
                                    helperText="직접 입력하거나 옆의 버튼을 통해 이미지를 업로드하세요."
                                />
                                <Button
                                    variant="outlined"
                                    component="label"
                                    disabled={uploading}
                                    sx={{ whiteSpace: 'nowrap', minWidth: '120px', height: '56px' }}
                                >
                                    {uploading ? <CircularProgress size={24} /> : '이미지 업로드'}
                                    <input type="file" hidden accept="image/*" onChange={handleFileUpload} />
                                </Button>
                            </Box>
                        </Grid>
                        <Grid size={12}>
                            <Typography variant="subtitle2" color="primary" sx={{ mb: 1 }}>영화 소개 음성 (MP3)</Typography>
                            <Box sx={{ display: 'flex', gap: 2, alignItems: 'center' }}>
                                <TextField
                                    fullWidth
                                    label="음성 파일 URL"
                                    name="audioIntroUrl"
                                    value={formData.audioIntroUrl || ''}
                                    onChange={handleInputChange}
                                    helperText="직접 입력하거나 옆의 버튼을 통해 MP3 파일을 업로드하세요."
                                />
                                <Button
                                    variant="outlined"
                                    component="label"
                                    disabled={uploading}
                                    sx={{ whiteSpace: 'nowrap', minWidth: '120px', height: '56px' }}
                                >
                                    {uploading ? <CircularProgress size={24} /> : 'MP3 업로드'}
                                    <input type="file" hidden accept="audio/mp3,audio/mpeg" onChange={handleAudioUpload} />
                                </Button>
                            </Box>
                            {formData.audioIntroUrl && (
                                <Box sx={{ mt: 1 }}>
                                    <audio controls src={formData.audioIntroUrl} style={{ width: '100%', maxWidth: '400px' }} />
                                </Box>
                            )}
                        </Grid>
                        <Grid size={12}><Typography variant="subtitle2" color="primary">베리어프리 리소스</Typography></Grid>
                        <Grid size={{ xs: 12, sm: 6 }}>
                            <FormControlLabel control={<Checkbox name="hasAudioCommentary" checked={formData.hasAudioCommentary} onChange={handleInputChange} />} label="화면해설 제공" />
                            <TextField fullWidth size="small" label="파일 경로" name="audioCommentaryFile" value={formData.audioCommentaryFile} onChange={handleInputChange} disabled={!formData.hasAudioCommentary} />
                        </Grid>
                        <Grid size={{ xs: 12, sm: 6 }}>
                            <FormControlLabel control={<Checkbox name="hasClosedCaption" checked={formData.hasClosedCaption} onChange={handleInputChange} />} label="폐쇄자막 제공" />
                            <TextField fullWidth size="small" label="파일 경로" name="closedCaptionFile" value={formData.closedCaptionFile} onChange={handleInputChange} disabled={!formData.hasClosedCaption} />
                        </Grid>
                    </Grid>
                </DialogContent>
                <DialogActions>
                    <Button onClick={handleCloseDialog}>취소</Button>
                    <Button onClick={handleSubmit} variant="contained" color="primary">저장</Button>
                </DialogActions>
            </Dialog>
        </Box>
    );
};

export default Movies;
